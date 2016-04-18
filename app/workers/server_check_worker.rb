class ServerCheckWorker
  include Sidekiq::Worker

  def perform(id)
    @server = Server.find(id)
    return if @server.states.count < 2
    @old_state = @server.is_ok
    @ram_threshold = @old_state ? 85 : 80
    @swap_threshold = @old_state ? 30 : 20
    @new_state = true
    @messages = []

    check_load_current_cpu
    check_load_current_mem
    check_load_current_swap
    check_load_change_cpu
    memory_leak_detection
    save_data
    send_notifications
  end

private

  def check_load_change_cpu
    @states = @server.states.order(:created_at.desc).limit(10).reverse
    x_mean = @states.map(&:created_at).map(&:to_i).sum / @states.count
    y_mean = @states.map(&:cpu_load).sum / @states.count

    numerator = @states.map { |state| (state.created_at.to_i - x_mean) * (state.cpu_load - y_mean) }.sum

    denominator = @states.map { |state| (state.created_at.to_i - x_mean) ** 2 }.sum
    k = numerator.to_f / denominator
    return if k <= 0.2
    @new_state = false
    @messages << 'strange CPU load change'
  end

  def check_load_current_cpu
    @states = @server.states.order(:created_at.desc).limit(6)
    if @states.all? { |x| x.cpu_load > 90 }
      @new_state = false
      @messages << 'CPU load is too high'
    end
  end

  def check_load_current_mem
    @states = @server.states.order(:created_at.desc).limit(6)
    if @states.all? { |x| x.ram_usage > @ram_threshold }
      @new_state = false
      @messages << 'RAM usage is too high'
    end
  end

  def check_load_current_swap
    @states = @server.states.order(:created_at.desc).limit(6)
    if @states.all? { |x| x.swap_usage > @swap_threshold }
      @new_state = false
      @messages << 'SWAP usage is too high'
    end
  end

  def memory_leak_detection
    states = @server.log_states.order(:created_at.asc).where(:created_at.gt => 12.hours.ago)
    ram_usages = states.pluck(:ram_usage)
    swap_usages = states.pluck(:swap_usage)
    pattern = ram_usages.size.times.map { |x| x }

    if dtw(ram_usages, pattern) < 100 || dtw(swap_usages, pattern) < 100
      @new_state = false
      @messages << 'possible memory leak'
    end
  rescue
    nil
  end

  def dtw(input, pattern)
    # coerce inputs to range 0..100
    input_min = input.min
    input = input.map { |x| x - input_min }
    scale_correction = 100.0 / input.max
    input = input.map { |x| x * scale_correction }

    pattern_min = pattern.min
    pattern = pattern.map { |x| (x - pattern_min) * scale_correction }
    scale_correction = 100.0 / pattern.max
    pattern = pattern.map { |x| x * scale_correction }

    distances = Array.new(input.size) { Array.new(pattern.size, 0) }
    distances[0] = distances.map { |x| Float::INFINITY }
    input.size.times { |x| distances[x][0] = Float::INFINITY }
    distances[0][0] = 0

    input.each_with_index do |input_el, input_index|
      pattern.each_with_index do |pattern_el, pattern_index|
        next if pattern_index == 0 || input_index == 0

        cost = (input_el - pattern_el).abs
        distances[input_index][pattern_index] = cost +
          [
            distances[input_index - 1][pattern_index],
            distances[input_index][pattern_index - 1],
            distances[input_index - 1][pattern_index - 1]
          ].min
      end
    end

    distances.last.last
  end


  def save_data
    @server.update(is_ok: @new_state, problems: @messages.join(' and '))
    @server.project.recalc_state
  end

  def send_notifications
    message = @messages.join(' and ')
    if @old_state && !@new_state
      MailerService.new.send_server_bad(@server, message)
    end
  end
end

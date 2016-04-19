class ServerCheckWorker
  include Sidekiq::Worker

  def perform(id)
    @server = Server.find(id)
    return if @server.states.count < 2
    @old_state = @server.is_ok
    @new_state = nil
    @messages = []
    @states = @server.states.order(:created_at.desc).limit(6)

    check_is_bad
    check_is_good

    save_data
    send_notifications
  end

private

  def check_is_bad
    check_load_current_cpu
    check_load_current_mem
    check_load_current_swap
    memory_leak_detection
  end

  def check_is_good
    return unless @new_state.nil?
    return if @states.any? { |x| x.cpu_load > 80 || x.ram_usage > 80 || x.swap_usage > 25 }
    @new_state = true
  end

  def check_load_current_cpu
    if @states.all? { |x| x.cpu_load > 90 }
      @new_state = false
      @messages << 'CPU load is too high'
    end
  end

  def check_load_current_mem
    if @states.all? { |x| x.ram_usage > 90 }
      @new_state = false
      @messages << 'RAM usage is too high'
    end
  end

  def check_load_current_swap
    if @states.all? { |x| x.swap_usage > 35 }
      @new_state = false
      @messages << 'SWAP usage is too high'
    end
  end

  def memory_leak_detection
    states = @server.log_states.order(:created_at.asc).where(:created_at.gt => 12.hours.ago)
    ram_usages = states.pluck(:ram_usage)
    swap_usages = states.pluck(:swap_usage)
    return if (ram_usages.max - ram_usages.min) < 10 && (swap_usages.max - swap_usages.min) < 10
    pattern = ram_usages.size.times.map { |x| x }

    if dtw(ram_usages, pattern) < 50 || dtw(swap_usages, pattern) < 100
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
    return if @new_state.nil?
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

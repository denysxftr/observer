class MemoryLeakDetectWorker
  include Sidekiq::Worker

  def perform(id)
    @server = Server.find(id)
    return if @server.states.count < 200
    @detected_before = @server.issues.include?(:memory_leak)
    @is_detected = false
    memory_leak_detection

    save_data
    send_notifications
  end

private

  def memory_leak_detection
    states = @server.states.order(:created_at.asc).where(:created_at.gt => 12.hours.ago).pluck(:ram_usage, :swap_usage)
    data = states.map { |x| x.sum }
    return if (data.max - data.min) < 10
    pattern = data.size.times.map { |x| x }
    if dtw(data, pattern) < 1000
      @is_detected = true
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
    if @is_detected
      @server.issues << :memory_leak
    else
      @server.issues.delete(:memory_leak)
    end
    @server.issues.uniq!

    @server.save
    @server.project&.recalc_state
  end

  def send_notifications
    if !@detected_before && @is_detected
      MailerService.new.send_server_bad(@server)
    end
  end
end

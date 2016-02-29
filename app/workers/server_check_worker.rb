class ServerCheckWorker
  include Sidekiq::Worker

  def perform(id)
    @server = Server.find(id)
    return if @server.states.count < 2
    @old_state = @server.is_ok
    @new_state = true
    @messages = []

    check_load_current_cpu
    check_load_current_mem
    check_load_change_cpu
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
    if @states.all? { |x| x.ram_usage > 90 }
      @new_state = false
      @messages << 'RAM usage is too high'
    end
  end

  def save_data
    @server.update(is_ok: @new_state)
    @server.project.recalc_state
  end

  def send_notifications
    message = @messages.join(' and ')
    if @old_state && !@new_state
      MailerService.new.send_server_bad(@server, message)
    end
  end
end

class ServerCheckWorker
  include Sidekiq::Worker

  def perform(id)
    @server = Server.find(id)
    @old_state = @server.is_ok
    @new_state = true

    check_load_current
    check_load_change
    save_data
    send_notifications
  end

private

  def check_load_change
    @states = @server.states.order(:created_at.desc).limit(10).reverse
    return if @states.count <= 1
    x_mean = @states.map(&:created_at).map(&:to_i).sum / @states.count
    y_mean = @states.map(&:cpu_load).sum / @states.count

    numerator = @states.map { |state| (state.created_at.to_i - x_mean) * (state.cpu_load - y_mean) }.sum

    denominator = @states.map { |state| (state.created_at.to_i - x_mean) ** 2 }.sum
    k = numerator.to_f / denominator
    return if k <= 0.2
    @new_state = false
    @message = 'strange CPU load change'
  end

  def check_load_current
    @states = @server.states.order(:created_at.desc).limit(6)
    if @states.all? { |x| x.cpu_load > 90 }
      @new_state = false
      @message = 'CPU load is too high'
    end
  end

  def save_data
    @server.update(is_ok: @new_state)
    @server.project.recalc_state
  end

  def send_notifications
    if @old_state && !@new_state
      MailerService.new.send_server_bad(@server, @message)
    end
  end
end

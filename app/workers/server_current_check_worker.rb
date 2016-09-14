class ServerCurrentCheckWorker
  include Sidekiq::Worker

  def perform(id)
    @server = Server.find(id)
    return if @server.states.count < 2
    @issues = []
    @old_issues = @server.issues
    @states = @server.states.order(:created_at.desc).limit(6)

    check_load_current_cpu
    check_load_current_mem
    check_load_current_swap

    save_data
    send_notifications
  end

private

  def check_load_current_cpu
    threshold = @server.issues.include?(:cpu_high) ? 80 : 90
    if @states.all? { |x| x.cpu_load > threshold }
      @issues << :cpu_high
    end
  end

  def check_load_current_mem
    threshold = @server.issues.include?(:ram_high) ? 85 : 90
    if @states.all? { |x| x.ram_usage > threshold }
      @issues << :ram_high
    end
  end

  def check_load_current_swap
    threshold = @server.issues.include?(:swap_usage) ? 30 : 35
    if @states.all? { |x| x.swap_usage > threshold }
      @issues << :swap_high
    end
  end

  def save_data
    @issues << :memory_leak if @server.issues.include?(:memory_leak)
    @server.update(is_ok: @issues.empty?, issues: @issues)
    @server.project&.recalc_state
  end

  def send_notifications
    if @issues.count >= @old_issues.count && @issues.sort != @old_issues.sort
      MailerService.new.send_server_bad(@server)
    end
  end
end

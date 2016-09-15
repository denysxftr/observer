class CheckPerformWorker
  include Sidekiq::Worker
  SLEEP_TIME = ENV['RACK_ENV'] == 'production' ? 10 : 0

  def perform(id)
    @check = Check.find(id)
    @result = Result.new
    perform_check
    save_data
    send_notifications
  end

  private

  def perform_check
    @check.retries.times.any? { http_check }
    ip_resolving_check
    results_check
  end

  def save_data
    @result.is_ok = @result.issues.empty?
    @result.save
    @check.update(is_ok: @result.is_ok)
  end

  def send_notifications
    send_failure_emails if @check.previous_changes[:is_ok] == [true, false]
    send_successful_emails if @check.previous_changes[:is_ok] == [false, true]
  end

  def http_check
    @result.status = nil
    start_time = Time.now
    request = HTTP
      .timeout(write: 5, connect: 5, read: 10)
      .get(@check.url)
    @result.timeout = (Time.now - start_time) * 1000
    @result.status = request.status
  rescue Errno::ECONNREFUSED, Errno::ENETDOWN, Errno::ETIMEDOUT, SocketError, IOError, URI::InvalidURIError, HTTP::TimeoutError, HTTP::ConnectionError
  ensure
    sleep(1) unless @result.status
  end

  def ip_resolving_check
    @result.ip = `dig @8.8.8.8 #{@check.host} A +short`.strip
  end

  def results_check
    unless @result.status
      @result.issues[:network] = "Host is down."
      return
    end


    if !@check.expected_ip.blank? && @result.ip != @check.expected_ip
      @result.issues[:ip] = "'A' records error. Expected to have '#{@check.expected_ip}' got '#{@result.ip}'."
    end


    if !@check.expected_status.blank? && @result.status != @check.expected_status
      @result.issues[:status] = "Response status error. Expected #{@check.expected_status} got #{@result.status}."
    end
  end

  def send_failure_emails
    MailerService.new.send_host_failed_email(@result)
  end

  def send_successful_emails
    MailerService.new.send_host_success_email(@result)
  end
end

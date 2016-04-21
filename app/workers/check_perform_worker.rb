class CheckPerformWorker
  include Sidekiq::Worker

  def perform(id)
    @check = Check.find(id)
    @old_state = @check.is_ok
    check_http
    save_data
    check_result
  end

  private

  def save_data
    Result.create(is_ok: @result, timeout: @response_time, status: @status, check: @check)
  end

  def check_http
    3.times.any? { |_x| respond_to_http? }
    @check.update(is_ok: @result)
  end

  def check_result
    if @old_state && !@check.is_ok
      send_failure_emails
    elsif !@old_state && @check.is_ok
      send_successful_emails
    end
    @check.project.recalc_state
  end

  def respond_to_http?
    start_time = Time.now
    request = HTTP
      .timeout(write: 5, connect: 5, read: 10)
      .get(@check.url)
    @response_time = (Time.now - start_time) * 1000
    @result = request.status < 400
    @status = request.status
    sleep(10) unless @result
    @result
  rescue Errno::ECONNREFUSED, Errno::ENETDOWN, Errno::ETIMEDOUT, SocketError, IOError, URI::InvalidURIError
    @result = false
    @response_time = nil
    sleep(10)
    @result
  end

  def send_failure_emails
    MailerService.new.send_host_failed_email(@check)
  end

  def send_successful_emails
    MailerService.new.send_host_success_email(@check)
  end
end

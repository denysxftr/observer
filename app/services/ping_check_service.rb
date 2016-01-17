class PingCheckService
  def initialize(id)
    @ping = Ping[id]
  end

  def perform
    @old_state = @ping.is_ok
    @ping.is_ping ? check_ping : check_http
    save_data
    check_result
  end

  private

  def save_data
    REDIS.set("checklog:#{@ping.id}:#{Time.now.to_i}", @response_time || -1, ex: 86400)
  end

  def check_ping
    3.times.any? { |_x| respond_to_ping? }
    @ping.update(last_response_time: @response_time, is_ok: @result)
  end

  def check_http
    3.times.any? { |_x| respond_to_http? }
    @ping.update(last_response_time: @response_time, is_ok: @result)
  end

  def check_result
    if @old_state && !@ping.is_ok
      send_failure_emails
    elsif !@old_state && @ping.is_ok
      send_successful_emails
    end
  end

  def respond_to_http?
    start_time = Time.now
    request = HTTP.get(@ping.url)
    @response_time = (Time.now - start_time) * 1000
    @result = request.status < 400
    sleep(10) unless @result
    @result
  rescue Errno::ECONNREFUSED, Errno::ENETDOWN, SocketError, IOError, URI::InvalidURIError
    @result = false
    @response_time = nil
    sleep(10)
    @result
  end

  def respond_to_ping?
    start_time = Time.now
    ping = Net::Ping::External.new(@ping.url)
    @result = ping.ping?
    @response_time = (Time.now - start_time) * 1000
    sleep(10) unless @result
    @result
  end

  def send_failure_emails
    MailerService.new.send_host_failed_email(@ping)
  end

  def send_successful_emails
    MailerService.new.send_host_success_email(@ping)
  end
end

class PingCheckService
  def initialize(id)
    @ping = Ping[id]
  end

  def perform
    @old_state = @ping.is_ok
    @ping.is_ping ? check_ping : check_http
    check_result
  end

  private

  def check_ping
    start_time = Time.now
    ping = Net::Ping::External.new(@ping.url)
    result = ping.ping?
    response_time = (Time.now - start_time) * 1000
    @ping.update(last_response_time: response_time, is_ok: result)
  end

  def check_http
    start_time = Time.now
    request = HTTP.get(@ping.url)
    response_time = (Time.now - start_time) * 1000
    @ping.update(last_response_time: response_time, is_ok: request.status < 400)
  rescue Errno::ECONNREFUSED, SocketError
    @ping.update(last_response_time: nil, is_ok: false)
  end

  def check_result
    if @old_state && !@ping.is_ok
      send_failure_emails
    elsif !@old_state && @ping.is_ok
      send_successful_emails
    end
  end

  def send_failure_emails

  end

  def send_successful_emails

  end
end

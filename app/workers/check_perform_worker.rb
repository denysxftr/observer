class CheckPerformWorker
  include Sidekiq::Worker
  SLEEP_TIME = ENV['RACK_ENV'] == 'production' ? 10 : 1

  def perform(id)
    @check = Check.find(id)
    @result = Result.new(check: @check)
    perform_check
    save_data
    send_notifications
  end

  private

  def perform_check
    resolving_thread = Thread.new { @check.retries.times.any? { ip_resolving_check } }
    @check.retries.times.any? { http_check }
    resolving_thread.join
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
    conn = Faraday.new(@check.url)
    start_time = Time.now
    response = conn.get do |req|
      req.options.timeout = 20
    end
    @result.timeout = (Time.now - start_time) * 1000
    @result.status = response.status
  rescue Errno::ECONNREFUSED, Errno::ENETDOWN, Errno::ETIMEDOUT, SocketError, IOError, URI::InvalidURIError,
      Faraday::ConnectionFailed, Faraday::ResourceNotFound, Faraday::TimeoutError, Faraday::ParsingError => e
    Sidekiq.logger.warn(e.inspect)
    @other_error = e.message
  rescue OpenSSL::SSL::SSLError, Faraday::SSLError
    @ssl_error = true
  ensure
    sleep(SLEEP_TIME) unless @result.status
  end

  def ip_resolving_check
    @result.ip = `dig @8.8.8.8 #{@check.host} A +short`.strip
    sleep(SLEEP_TIME) if @result.ip.empty? || @result =~ /connection/
    !@result.ip.empty?
  end

  def results_check
    if @ssl_error
      @result.issues[:ssl] = "SSL error."
      return
    end

    unless @result.status
      @result.issues[:network] = "Host is down: #{@other_error}"
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
    MailerWorker.perform_async(@result.id, :send_host_failed_email)
  end

  def send_successful_emails
    MailerWorker.perform_async(@result.id, :send_host_success_email)
  end
end

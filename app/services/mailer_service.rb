class MailerService
  def send_host_failed_email(result_id)
    @result = Result.find(result_id)
    @check = result.check
    @emails = @check.emails
    send_emails("Observer: #{@check.name_with_project} check failed!", 'host_down')
  end

  def send_host_success_email(result_id)
    @result = Result.find(result_id)
    @check = result.check
    @emails = @check.emails
    send_emails("Observer: #{@check.name_with_project} check succeed!", 'host_up')
  end

  def send_server_bad(server_id)
    @server = Server.find(server_id)
    @emails = server.emails
    send_emails("Observer: #{@server.name_with_project} overload!", 'server_bad')
  end

private

  def render(action)
    ERB.new(File.read("./app/views/mailer/#{action}.erb")).result(binding)
  end

  def send_emails(subject, action)
    Mailer.send_message(APP_CONFIG['mailgun_domain'],
    from: APP_CONFIG['email_from'],
    to: emails,
    subject: subject,
    html: render(action))
  end

  def emails
    @emails.empty? ? APP_CONFIG['default_emails'] : @emails
  end
end

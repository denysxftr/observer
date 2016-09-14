class MailerService
  def send_host_failed_email(check)
    @check = check
    @emails = check.emails
    send_emails("Observer: #{@check.name_with_project} check failed!", 'host_down')
  end

  def send_host_success_email(check)
    @check = check
    @emails = check.emails
    send_emails("Observer: #{@check.name_with_project} check succeed!", 'host_up')
  end

  def send_server_bad(server)
    @server = server
    @emails = server.emails
    send_emails("Observer: #{@server.name_with_project} overload!", 'server_bad')
  end

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

private

  def emails
    @emails.empty? ? APP_CONFIG['default_emails'] : @emails
  end
end

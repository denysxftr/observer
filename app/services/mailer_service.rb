class MailerService
  def send_host_failed_email(ping)
    @ping = ping
    send_emails("Observer: #{@ping.host} check failed!", 'host_down')
  end

  def send_host_success_email(ping)
    @ping = ping
    send_emails("Observer: #{@ping.host} check succeed!", 'host_up')
  end

  def render(action)
    ERB.new(File.read("#{ObserverApp.views}/mailer/#{action}.erb")).result(binding)
  end

  def send_emails(subject, action)
    emails = User.select_map(:email)
    Mailer.send_message(APP_CONFIG['mailgun_domain'],
      from: APP_CONFIG['email_from'],
      to: emails,
      subject: subject,
      html: render(action))
  end
end

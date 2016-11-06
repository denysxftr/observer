class MailerWorker
  include Sidekiq::Worker

  def perform(entity_id, name)
    MailerService.new.send(name, entity_id)
  end
end

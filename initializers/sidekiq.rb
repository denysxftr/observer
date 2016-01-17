Sidekiq.configure_server do |config|
  config.options[:concurrency] = 50
end

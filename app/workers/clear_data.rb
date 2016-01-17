class ClearData
  include Sidekiq::Worker

  def perform
    Check.all.each do |check|
      check.results.where(:created_at.lt => Time.at(Time.now.utc.to_i - 86400)).delete
    end
    Server.all.each do |server|
      server.states.where(:created_at.lt => Time.at(Time.now.utc.to_i - 86400)).delete
    end
  end
end

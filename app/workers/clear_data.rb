class ClearData
  include Sidekiq::Worker

  def perform
    Result.where(:created_at.lt => Time.at(Time.now.utc.to_i - 86400)).delete_all
    State.where(:created_at.lt => Time.at(Time.now.utc.to_i - 86400)).delete_all
  end
end

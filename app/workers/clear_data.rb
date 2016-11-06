class ClearData
  include Sidekiq::Worker

  def perform
    Result.where(:created_at.lt => 1.week.ago).delete_all
    State.where(:created_at.lt => 1.day.ago).delete_all
  end
end

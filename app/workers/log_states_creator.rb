class LogStatesCreator
  include Sidekiq::Worker

  def perform
    Server.all.each { |s| create_log(s) }
  end

private

  def create_log(server)
    return if server.log_states.where(:created_at.gt => Time.at(Time.now.utc.to_i - 3600)).exists?
    states = states(server)
    LogState.create(
      server: server,
      cpu_load: average(states.pluck(:cpu_load)),
      ram_usage: average(states.pluck(:ram_usage)),
      swap_usage: average(states.pluck(:swap_usage))
    )
  end

  def states(server)
    server.states.where(:created_at.gt => Time.at(Time.now.utc.to_i - 3600))
  end

  def average(values)
    return 0 if values.empty?
    (values.inject(:+) / values.size.to_f).round(1)
  end
end

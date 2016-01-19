class IncidentSaver
  def initialize(server:, headline:, description: '')
    @server = server
    @headline = headline
    @description = description
  end

  def perform
    Incident.create(
      server: server,
      states: server_states,
      headline: headline,
      description: description
    )
  end

private

  def server_states
    @server.states
      .where(:created_at.gt => Time.at(Time.now.utc - 3600))
      .map { |state| { cpu: state.cpu_load, ram: state.ram_usage } }
  end
end

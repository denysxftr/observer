get '/incident/:id' do
  protect!
  @incident = Incident.find(params[:id])
  erb :'incidents/show'
end

get '/incident/:id/data' do
  protect!
  incident = Incident.find(params[:id])
  data = {
    cpu_usage: incident.states.map { |x| x['cpu_usage'] },
    ram_usage: incident.states.map { |x| x['ram_usage'] },
    swap_usage: incident.states.map { |x| x['swap_usage'] }
  }
end

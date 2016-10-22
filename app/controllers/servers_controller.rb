get '/server/new' do
  protect!
  @server = Server.new
  erb :'servers/new'
end

post '/server/new' do
  protect!
  @server = Server.new(server_params)
  @server.save

  finish_action @server
end

get '/servers' do
  protect!
  @servers = Server.all
  erb :'servers/index'
end

get '/server/:id' do
  protect!
  @server = Server.find(params[:id])
  erb :'servers/show'
end

get '/server/:id/edit' do
  protect!
  @server = Server.find(params[:id])
  erb :'servers/edit'
end

get '/server/:id/last_day' do
  protect!
  @server = Server.find(params[:id])
  erb :'servers/last_day'
end


get '/server/:id/last_month' do
  protect!
  @server = Server.find(params[:id])
  erb :'servers/last_month'
end

get '/server/:id/data' do
  protect!
  states = server_states(unit: :hours)

  json states_data states
end

get '/server/:id/log_data' do
  protect!
  states = server_states(unit: :days)

  json states_data states
end

post '/server/:id' do
  protect!
  @server = Server.find(params[:id])
  @server.update(server_params)

  finish_update_action @server
end

post '/servers/:id/delete' do
  protect!
  Server.find(params[:id]).delete
  session[:success] = 'Server deleted'
  redirect "/"
end

def server_states(unit:)
  server = Server.find(params[:id])
  from = params[:from].to_i
  from += 1 if unit == :days
  (unit == :days ? server.log_states : server.states)
    .where(:created_at.gt => from.send(unit).ago, :created_at.lt => params[:to].to_i.send(unit).ago)
    .order_by(created_at: 'asc')
end

def states_data(states)
   {
     time: states.pluck(:created_at).map { |x| (x.utc + params[:timezone].to_i.hours).strftime('%Y-%m-%d %H:%M:%S') },
     cpu: states.pluck(:cpu_load).map(&:to_i),
     ram: states.pluck(:ram_usage).map(&:to_i),
     swap: states.pluck(:swap_usage).map(&:to_i)
   }
end

get '/project/:project_id/server/new' do
  protect!
  @server = Server.new
  erb :'servers/new'
end

post '/project/:project_id/server/new' do
  protect!
  @server = Server.new(
    name: params[:name],
    project: Project.find(params[:project_id])
  )
  @server.save

  if @server.valid?
    redirect "/project/#{params[:project_id]}"
  else
    session[:alert] = @server.errors.full_messages.join(' ')
    erb :'servers/new'
  end
end

get '/server/:id/edit' do
  protect!
  @server = Server.find(params[:id])
  erb :'servers/edit'
end

get '/server/:id' do
  protect!
  @server = Server.find(params[:id])
  erb :'servers/show'
end

get '/server/:id/last_day' do
  protect!
  @server = Server.find(params[:id])
  erb :'servers/last_day'
end

get '/server/:id/last_hour' do
  protect!
  @server = Server.find(params[:id])
  erb :'servers/last_hour'
end

get '/server/:id/last_month' do
  protect!
  @server = Server.find(params[:id])
  erb :'servers/last_month'
end

get '/server/:id/data' do
  protect!
  server = Server.find(params[:id])
  states = server.states.where(:created_at.gt => Time.at(Time.now.utc.to_i - params[:time].to_i * 3600)).order_by(created_at: 'asc')
  data = {
    time: states.pluck(:created_at).map { |x| x.utc.strftime('%Y-%m-%d %H:%M:%S') },
    cpu: states.pluck(:cpu_load).map(&:to_i),
    ram: states.pluck(:ram_usage).map(&:to_i),
    swap: states.pluck(:swap_usage).map(&:to_i)
  }

  json data
end

get '/server/:id/log_data' do
  protect!
  server = Server.find(params[:id])
  states = server.log_states.where(:created_at.gt => Time.at(Time.now.utc.to_i - params[:time].to_i * 86400)).order_by(created_at: 'asc')
  data = {
    time: states.pluck(:created_at).map { |x| x.utc.strftime('%Y-%m-%d %H:%M:%S') },
    cpu: states.pluck(:cpu_load).map(&:to_i),
    ram: states.pluck(:ram_usage).map(&:to_i),
    swap: states.pluck(:swap_usage).map(&:to_i)
  }

  json data
end

post '/server/:id' do
  protect!
  @server = Server.find(params[:id])
  @server.update(
    name: params[:name]
  )
  redirect "/server/#{params[:id]}"
end

post '/servers/:id/delete' do
  protect!
  server = Server.find(params[:id])
  server.delete
  redirect "/project/#{server.project.id}"
end

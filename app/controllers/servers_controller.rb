get '/server/new' do
  protect!
  @server = Server.new
  erb :'servers/new'
end

post '/server/new' do
  protect!
  @server = Server.new(
    name: params[:name],
    project: !params[:project_id].empty? && Project.find(params[:project_id]),
    emails: params[:emails]
  )
  @server.save

  if @server.valid?
    redirect "/server/#{@server.id}"
  else
    session[:alert] = @server.errors.full_messages.join(' ')
    erb :'servers/new'
  end
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
  server = Server.find(params[:id])
  states = server.states
    .where(:created_at.gt => params[:from].to_i.hours.ago, :created_at.lt => params[:to].to_i.hours.ago)
    .order_by(created_at: 'asc')

  data = {
    time: states.pluck(:created_at).map { |x| (x.utc + params[:timezone].to_i.hours).strftime('%Y-%m-%d %H:%M:%S') },
    cpu: states.pluck(:cpu_load).map(&:to_i),
    ram: states.pluck(:ram_usage).map(&:to_i),
    swap: states.pluck(:swap_usage).map(&:to_i)
  }

  json data
end

get '/server/:id/log_data' do
  protect!
  server = Server.find(params[:id])
  states = server.log_states
    .where(:created_at.gt => params[:from].to_i.days.ago, :created_at.lt => params[:to].to_i.days.ago)
    .order_by(created_at: 'asc')

  data = {
    time: states.pluck(:created_at).map { |x| (x.utc + params[:timezone].to_i.hours).strftime('%Y-%m-%d %H:%M:%S') },
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
    name: params[:name],
    project: !params[:project_id].empty? && Project.find(params[:project_id]),
    emails: params[:emails]
  )
  redirect "/server/#{params[:id]}"
end

post '/servers/:id/delete' do
  protect!
  server = Server.find(params[:id])
  server.delete
  session[:success] = 'Server deleted'
  redirect "/"
end

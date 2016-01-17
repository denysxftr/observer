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
    erb :'server/new'
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

get '/server/:id/data' do
  protect!
  server = Server.find(params[:id])
  data = {
    time: server.states.pluck(:created_at).map { |x| x.strftime('%Y-%m-%d %H:%M:%S') },
    cpu: server.states.pluck(:cpu_load)
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

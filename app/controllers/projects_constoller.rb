get '/projects' do
  protect!
  @projects = Project.order_by(:name.asc)
  erb :'projects/index'
end

get '/project/new' do
  protect!
  @project = Project.new
  erb :'projects/new'
end

post '/project/new' do
  protect!
  @project = Project.new(project_params(params))
  @project.save

  make_response @project
end

get '/project/:id' do
  protect!
  @project = Project.find(params[:id])
  erb :'projects/show'
end

get '/project/:id/edit' do
  protect!
  @project = Project.find(params[:id])
  erb :'projects/edit'
end

post '/project/:id' do
  protect!
  @project = Project.find(params[:id])
  @project.update(project_params(params))

  make_update_response @project
end

post '/projects/:id/delete' do
  protect!
  Project.find(params[:id]).delete
  redirect '/projects'
end

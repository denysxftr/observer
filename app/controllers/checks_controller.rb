
get '/project/:project_id/check/new' do
  protect!
  @check = Check.new
  erb :'checks/new'
end

post '/project/:project_id/check/new' do
  protect!
  @check = Check.new(
    url: params[:url],
    name: params[:name],
    project: Project.find(params[:project_id])
  )
  @check.save

  if @check.valid?
    redirect "/project/#{params[:project_id]}"
  else
    erb :'check/new'
  end
end

get '/check/:id' do
  protect!
  @check = Check.find(params[:id])
  erb :'checks/show'
end

get '/check/:id/edit' do
  protect!
  @check = Check.find(params[:id])

  erb :'checks/edit'
end

post '/check/:id' do
  protect!
  @check = Check.find(params[:id])
  @check.update(
    url: params[:url],
    is_ok: params[:is_ok],
    name: params[:name]
  )

  if @check.valid?
    redirect "/project/#{@check.project.id}"
  else
    erb :'check/edit'
  end
end

post '/check/:id/delete' do
  protect!
  Check.find(params[:id]).delete
  redirect '/checks'
end

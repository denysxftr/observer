get '/checks' do
  protect!
  @checks = Check.order(:url)
  erb :'checks/index'
end

get '/checks/new' do
  protect!
  @check = Check.new
  erb :'checks/new'
end

post '/checks' do
  protect!
  @check = Check.new(
    url: params[:url],
    is_ok: params[:is_ok],
    name: params[:name]
  )
  @check.save

  if @check.valid?
    redirect '/checks'
  else
    erb :'check/new'
  end
end

get '/check/:id' do
  protect!
  @check = Check.find(params[:id])
  if request.xhr?
    json @check
  else
    erb :'checks/show'
  end
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
    redirect '/checks'
  else
    erb :'check/edit'
  end
end

post '/check/:id/delete' do
  protect!
  Check.find(params[:id]).delete
  redirect '/checks'
end

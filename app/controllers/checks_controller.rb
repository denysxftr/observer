get '/check/new' do
  protect!
  @check = Check.new
  erb :'checks/new'
end

post '/check/new' do
  protect!
  @check = Check.new(
    url: params[:url],
    name: params[:name],
    project: !params[:project_id].empty? && Project.find(params[:project_id]),
    emails: params[:emails],
    is_ok: true
  )
  @check.save

  if @check.valid?
    redirect "/check/#{@check.id}"
  else
    session[:alert] = @check.errors.full_messages.join(' ')
    erb :'checks/new'
  end
end

get '/checks' do
  protect!
  @checks = Check.all.order_by(is_ok: :asc, name: :asc)
  erb :'checks/index'
end

get '/check/:id' do
  protect!
  @check = Check.find(params[:id])
  erb :'checks/show'
end

get '/check/:id/data' do
  protect!
  check = Check.find(params[:id])
  log = check.results.order(:created_at.asc).map { |x| [x.created_at.utc.strftime('%Y-%m-%d %H:%M:%S'), x.is_ok ? x.timeout : -1] }.to_h
  json({ log: log })
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
    name: params[:name],
    project: !params[:project_id].empty? && Project.find(params[:project_id]),
    emails: params[:emails]
  )

  if @check.valid?
    redirect "/check/#{@check.id}"
  else
    erb :'check/edit'
  end
end

post '/check/:id/delete' do
  protect!
  check = Check.find(params[:id])
  check.delete
  session[:success] = 'HTTP check deleted'
  redirect "/"
end

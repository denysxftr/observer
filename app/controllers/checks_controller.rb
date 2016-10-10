get '/check/new' do
  protect!
  @check = Check.new
  erb :'checks/new'
end

post '/check/new' do
  protect!
  @check = Check.new( check_params )
  @check.save

  validate_instance @check
end

get '/checks' do
  protect!
  @checks = Check.all.sort_by(&:name_with_project)
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
  results = check.results.order(:created_at.asc)
  json({ log: prepare_logs(results)})
end

get '/check/:id/edit' do
  protect!
  @check = Check.find(params[:id])

  erb :'checks/edit'
end

post '/check/:id' do
  protect!
  @check = Check.find(params[:id])
  @check.update( check_params )

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

def prepare_logs(results)
  results.map do |item|
    {
      time: item.created_at.utc.strftime('%Y-%m-%d %H:%M:%S'),
      timeout: item.timeout.to_i,
      issues: item.issues.values.join(' ')
    }
  end
end

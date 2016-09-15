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
    emails: params[:emails] || [],
    is_ok: true,
    expected_ip: params[:expected_ip],
    expected_status: params[:expected_status],
    retries: params[:retries]
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
  log = prepare_logs(results, is_ok: true)
  fails_log = prepare_logs(results, is_ok: false)
  json({ log: log, fails_log: fails_log })
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
    emails: params[:emails] || [],
    expected_ip: params[:expected_ip],
    expected_status: params[:expected_status],
    retries: params[:retries]
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

def prepare_logs(results, is_ok:)
  results.map do |x|
    [
      x.created_at.utc.strftime('%Y-%m-%d %H:%M:%S'),
      (is_ok ? x.is_ok : !x.is_ok) ? x.timeout.to_i : 0
    ]
  end.to_h
end

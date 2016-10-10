def validate_creating instanse
  if instanse.valid?
    redirect "/server/#{instanse.id}"
  else
    session[:alert] = instanse.errors.full_messages.join(' ')
    debugger
    erb :'servers/new'
  end
end

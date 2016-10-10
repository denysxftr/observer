def validate_instance instance
  if instance.valid?
    redirect "/#{instance.class.name.downcase}/#{instance.id}"
  else
    session[:alert] = instance.errors.full_messages.join(' ')
    erb :"#{instance.class.name.downcase}s/new"
  end
end

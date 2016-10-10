def validate_instance instance
  name_of_class = instance.class.name.downcase
  if instance.valid?
    redirect "/#{name_of_class}/#{instance.id}" unless (name_of_class == 'project'|| name_of_class == 'user')
    redirect "/#{name_of_class}s"
  else
    session[:alert] = instance.errors.full_messages.join(' ')
    erb :"#{name_of_class}s/new"
  end
end

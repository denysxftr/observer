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

def validate_updating instance
  if instance.valid?
    redirect "/#{instance.class.name.downcase}/#{instance.id}"
  else
    erb :"#{instance.class.name.downcase}s/edit"
  end
end

def server_params
  {
    name: params[:name],
    project: !params[:project_id].empty? && Project.find(params[:project_id]),
    emails: params[:emails] || []
  }
end

def project_params
  {
    name: params[name]
  }
end

def check_params
  {
    url: params[:url],
    name: params[:name],
    project: !params[:project_id].empty? && Project.find(params[:project_id]),
    emails: params[:emails] || [],
    expected_ip: params[:expected_ip],
    expected_status: params[:expected_status],
    retries: params[:retries]
  }
end

def user_params
  accepted_params = %w[email name].tap do |attrs|
    attrs << 'password' if @user&.new_record? || params[:password] && !params[:password].empty?
    attrs << 'role' if current_user.admin?
  end

  params.select { |k, v| accepted_params.include?(k) }
end

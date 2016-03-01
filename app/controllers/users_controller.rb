get '/users' do
  protect_admin!
  @users = User.all
  erb :'users/index'
end

get '/users/new' do
  protect_admin!
  @user = User.new
  erb :'users/new'
end

post '/users' do
  protect_admin!
  @user = User.new(user_params)
  @user.save
  if @user.valid?
    redirect '/users'
  else
    session[:alert] = @user.errors.full_messages.join(' ')
    erb :'users/new'
  end
end

get '/user/:id' do
  current_user_resource? || protect_admin!
  @user = User.find(params[:id])
  erb :'users/edit'
end

post '/user/:id' do
  current_user_resource? || protect_admin!
  @user = User.find(params[:id])
  @user.update(user_params)

  if @user.valid?
    session[:notice] = 'Profile updated'
    redirect '/users'
  else
    session[:alert] = @user.errors.full_messages.join(' ')
    erb :'users/edit'
  end
end

post '/user/:id/delete' do
  protect_admin!
  User.find(params[:id]).destroy
  redirect '/users'
end


def user_params
  accepted_params = %w[email name].tap do |attrs|
    attrs << 'password' if @user&.new_record? || params[:password] && !params[:password].empty?
    attrs << 'role' if current_user.admin?
  end

  params.select { |k, v| accepted_params.include?(k) }
end

class UsersController < ApplicationController
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
      erb :'user/new'
    end
  end

  get '/user/:id' do
    current_user_resource? || protect_admin!
    @user = User[params[:id]]
    erb :'users/edit'
  end

  post '/user/:id' do
    current_user_resource? || protect_admin!
    @user = User[params[:id]]
    @user.update(user_params)

    if @user.valid?
      session[:notice] = 'Profile updated'
      redirect '/users'
    else
      erb :'user/edit'
    end
  end

  post '/user/:id/delete' do
    protect_admin!
    User[params[:id]].destroy
    redirect :'/users'
  end

  private

  def user_params
    accepted_params = %w[email name].tap do |attrs|
      attrs << 'password' if @user.new? || params[:password] && !params[:password].empty?
      attrs << 'role' if current_user.admin?
    end

    params.select { |k, v| accepted_params.include?(k) }
  end
end

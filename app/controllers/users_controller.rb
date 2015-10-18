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
    @user = User.new(
      email: params[:email],
      name: params[:name],
      password_hash: Digest::SHA1.hexdigest(params[:password]),
      role: params[:role]
    )
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
    @user.update(
      email: params[:email],
      name: params[:name],
      role: params[:role]
    )

    if params[:password] && !params[:password].empty?
      @user.update(password_hash: Digest::SHA1.hexdigest(params[:password]))
    end

    if @user.valid?
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
end

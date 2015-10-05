class SessionController < ApplicationController
  get '/sign_in' do
    erb :'session/sign_in'
  end

  post '/sign_in' do
    user = User.find(email: params[:email], password_hash: Digest::SHA1.hexdigest(params[:password]))

    if user
      session[:id] = user.id
      session[:notice] = 'Signed in!'
      redirect '/'
    else
      session[:alert] = 'Login or password is wrong!'
      redirect '/sign_in'
    end
  end

  get '/sign_out' do
    protect!
    session[:id] = nil
    redirect '/sign_in'
  end
end

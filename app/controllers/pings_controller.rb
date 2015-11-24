class PingsController < ApplicationController
  get '/pings' do
    protect!
    @current_user = User.first
    @pings = Ping.order(:url)
    erb :'pings/index'
  end

  get '/pings/new' do
    protect!
    @ping = Ping.new
    erb :'pings/new'
  end

  post '/pings' do
    protect!
    @ping = Ping.new(
      url: params[:url],
      is_ping: params[:is_ping],
      http_method: params[:http_method]
    )
    @ping.save

    if @ping.valid?
      redirect '/pings'
    else
      erb :'ping/new'
    end
  end

  get '/ping/:id' do
    protect!
    @ping = Ping[params[:id]]

    erb :'pings/show'
  end

  post '/ping/:id' do
    protect!
    @ping = Ping[params[:id]]
    @ping.update(
      url: params[:url],
      is_ping: params[:is_ping],
      http_method: params[:http_method]
    )

    if @ping.valid?
      redirect '/pings'
    else
      erb :'ping/edit'
    end
  end

  post '/ping/:id/delete' do
    protect!
    Ping[params[:id]].delete
    redirect '/pings'
  end
end

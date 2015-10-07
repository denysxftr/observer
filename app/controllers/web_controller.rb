class WebController < ApplicationController
  get '/' do
    protect!
    redirect '/pings'
  end

  get '/settings' do
  end

  post '/settings' do
  end
end

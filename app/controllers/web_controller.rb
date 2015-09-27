class WebController < ApplicationController
  get '/' do
    protect!
    erb :welcome
  end

  get '/settings' do
  end

  post '/settings' do
  end
end

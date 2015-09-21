class WebController < ApplicationController
  get '/' do
    erb :welcome
  end

  get '/settings' do
  end

  post '/settings' do
  end
end

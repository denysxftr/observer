class WebController < ApplicationController
  get '/' do
    erb :welcome
  end
end
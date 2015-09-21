class ApplicationController < Sinatra::Base
  set :views, File.expand_path('./../../views', __FILE__)
end

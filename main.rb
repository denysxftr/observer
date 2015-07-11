require 'sinatra'

require './app/controllers/application_controller'
require './app/controllers/web_controller'

class ObserverApp < ApplicationController
  use WebController
end
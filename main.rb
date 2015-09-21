require 'sinatra'
require 'sqlite3'
require 'sequel'
require 'pry'

require './initializers/database'

require './app/controllers/application_controller'
require './app/controllers/web_controller'

class ObserverApp < ApplicationController
  use WebController
end

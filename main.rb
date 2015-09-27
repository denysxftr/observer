require 'sinatra'
require 'sqlite3'
require 'sequel'
require 'logger'
require 'json'
require 'digest/sha1'
require 'pry'

def load_path(path)
  Dir[path].each { |f| require f }
end

load_path('./initializers/*.rb')
load_path('./app/models/*.rb')
load_path('./app/controllers/*.rb')

class ObserverApp < ApplicationController
  [WebController, UsersController,PingsController, SessionController].each do |controller|
    use controller
  end
end

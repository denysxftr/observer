require 'sinatra'
require 'sqlite3'
require 'sequel'
require 'logger'
require 'json'
require 'digest/sha1'
require 'net/ping'
require 'http'
require 'pry'

Thread.abort_on_exception = true

def load_path(path)
  Dir[path].each { |f| require f }
end

load_path('./initializers/*.rb')
load_path('./app/models/*.rb')
load_path('./app/controllers/*.rb')
load_path('./app/services/*.rb')
load_path('./app/workers/*.rb')

CheckerDaemonWorker.new.start

class ObserverApp < ApplicationController
  [WebController, UsersController,PingsController, SessionController].each do |controller|
    use controller
  end
end

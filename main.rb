require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'] || :development)

require 'logger'
require 'json'
require 'digest/sha1'
require 'yaml'
require 'mailgun'
require 'securerandom'
require 'sidekiq/web'


APP_CONFIG = YAML.load_file('config/config.yml')

Thread.abort_on_exception = true

def load_path(path)
  Dir[path].sort.each { |f| require f }
end

load_path('./initializers/*.rb')
load_path('./app/helpers/*.rb')
load_path('./app/models/*.rb')
load_path('./app/controllers/*.rb')
load_path('./app/services/*.rb')
load_path('./app/workers/*.rb')

set :views, File.expand_path('./../app/views', __FILE__)
set :public_folder, File.expand_path('public')
enable :sessions
set :session_secret, "something"

def current_user
  @current_user ||= session[:id] && User.find(session[:id])
rescue Mongoid::Errors::DocumentNotFound
  session[:id] = nil
end

def current_user_resource?
  current_user && (params[:id].to_i == current_user.id)
end

def protect!
  redirect '/' if session[:id] && params[:splat] == 'sign_in'
  redirect '/sign_in' if !session[:id] && params[:splat] != ['sign_in']
end

def protect_admin!
  protect!
  redirect '/' unless current_user.admin?
end

helpers do
  include ApplicationHelper
end

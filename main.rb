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
  def alert
    session.delete(:alert)
  end

  def notice
    session.delete(:notice)
  end

  def assets_tags
    assets = nil
    tries = 5
    loop do
      assets = read_manifest rescue nil

      if assets
        break
      else
        puts 'Assets not ready'
        sleep(1)
      end

      puts('Assets not found!') if tries == 0
      tries -= 1
    end

    js_tag = "<script src='/assets/#{assets[:js]}' type='text/javascript'></script>"
    css_tag = "<link rel='stylesheet' type='text/css' href='/assets/#{assets[:css]}'>"

    js_tag + css_tag
  end

  def read_manifest
    result = {}
    manifest = JSON.parse(File.read(File.join(settings.public_folder, 'assets/manifest.json')))
    result[:js] = manifest['application.js']
    result[:css] = manifest['application.css']

    result
  end
end

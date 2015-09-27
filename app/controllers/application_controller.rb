class ApplicationController < Sinatra::Base
  set :views, File.expand_path('./../../views', __FILE__)
  set :public_folder, File.expand_path('public')

  def protect!
    redirect '/' if session[:id] && params[:splat] == 'sign_in'
    redirect '/sign_in' if !session[:id] && params[:splat] != ['sign_in']
  end

  helpers do
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

        raise('Assets not found!') if tries == 0
        tries -= 1
      end

      js_tag = "<script src='/assets/#{assets[:js]}' type='text/javascript'></script>"
      css_tag = "<link rel='stylesheet' src='/assets/#{assets[:css]}'>"

      js_tag + css_tag
    end

    def read_manifest
      result = {}
      manifest = JSON.parse(File.read(File.expand_path('public/assets/manifest.json')))
      result[:js] = manifest['application.js']
      result[:css] = manifest['application.css']

      result
    end
  end
end

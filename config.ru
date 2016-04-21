RUBY_GC_MALLOC_LIMIT=400010
RUBY_GC_MALLOC_LIMIT_MAX=1600010
RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.1

require './main'

run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)

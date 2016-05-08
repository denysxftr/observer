require 'yaml'
APP_CONFIG = YAML.load_file('config/config.yml')

threads 0,16
workers 1
# daemonize true
bind "tcp://#{APP_CONFIG['host']}"
pidfile 'tmp/puma.pid'

require 'http'
require 'usagewatch_ext'

token = ENV['TOKEN']
server = '127.0.0.1:3000'

loop do
  params = {
    cpu: 50 + rand(0..10),
    ram: 50 + rand(0..10)
  }
  HTTP.post(
    "http://#{server}/state/#{token}",
    params: params
  )
  sleep 10
end

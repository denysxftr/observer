require 'http'
require 'usagewatch_ext'

token = ENV['TOKEN']
server = '127.0.0.1:3000' 

loop do
  params = {
    cpu: Usagewatch.uw_cpuused,
    ram: Usagewatch.uw_memused
  }
  HTTP.post(
    "http://#{server}/state/#{token}",
    params: params
  )
  sleep 60
end

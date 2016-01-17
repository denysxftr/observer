require 'http'

token = ENV['TOKEN']

loop do
  p 'SEND' + Time.now.to_i.to_s
  HTTP.post(
    "http://localhost:3000/state/#{token}",
    params: {
      cpu: rand(50..60),
      ram: rand(500..600),
      ram_total: 1024
    }
  )
  sleep 60
end

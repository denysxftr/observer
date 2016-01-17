require './main'
loop do
  p 'Perform checks'
  Check.pluck(:id).each do |id|
    CheckPerformWorker.perform_async(id.to_s)
  end
  sleep 120
end

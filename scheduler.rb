require './main'
loop do
  p 'Perform checks'
  Check.pluck(:id).each do |id|
    CheckPerformWorker.perform_async(id.to_s)
  end
  Server.pluck(:id).each do |id|
    ServerCheckWorker.perform_async(id.to_s)
  end
  ClearData.perform_async
  sleep 120
end

class PingsCheckWorker
  def perform
    Ping.select_map(:id).each do |id|
      Thread.new do
        PingCheckService.new(id).perform
      end
    end
  end
end

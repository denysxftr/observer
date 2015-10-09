class CheckerDaemonWorker
  def start
    Thread.new do
      loop do
        PingsCheckWorker.new.perform
        sleep(30)
      end
    end
  end
end

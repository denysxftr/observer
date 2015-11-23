class CheckerDaemonWorker
  def start
    Thread.new do
      loop do
        PingsCheckWorker.new.perform
        sleep(120)
      end
    end
  end
end

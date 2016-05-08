require './main'

class Processing < Thor
  desc 'states_check', 'perform current state check'
  def states_check
    Server.pluck(:id).each do |id|
      ServerCurrentCheckWorker.perform_async(id.to_s)
    end
  end

  desc 'http_check', 'perform HTTP checks'
  def http_check
    Check.pluck(:id).each do |id|
      CheckPerformWorker.perform_async(id.to_s)
    end
  end

  desc 'trends_check', 'perform state trends checks'
  def trends_check
    Server.pluck(:id).each do |id|
      MemoryLeakDetectWorker.new.perform(id.to_s)
      sleep 1
    end
  end

  desc 'create_log_states', 'creates long live logs'
  def create_log_states
    LogStatesCreator.perform_async
  end

  desc 'clear_old', 'clears old useless data'
  def clear_old
    ClearData.perform_async
  end
end

class System < Thor
  desc 'create_indexes', 'perform indexes creation'
  def create_indexes
    ::Mongoid::Tasks::Database.create_indexes
  end
end

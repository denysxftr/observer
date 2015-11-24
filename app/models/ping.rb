class Ping < Sequel::Model
  def host
    is_ping ? url : URI.parse(url).host
  end

  def timeouts_log
    keys = REDIS.keys("checklog:#{self.id}:*").sort
    values = REDIS.mget(keys)
    keys.each_with_index.map do |key, index|
      [Time.at(key.split(':').last.to_i).utc, values[index].to_i]
    end.to_h
  end

  def validate
    super
    %i(url http_method).each do |attr|
      errors.add(attr, 'cannot be empty') if !send(attr) || send(attr).empty?
    end
  end

  def before_save
    self.url = 'http://' + url unless self.is_ping || self.url =~ /^http(s)?:\/\//
    super
  end
end

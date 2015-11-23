class Ping < Sequel::Model
  def host
    is_ping ? url : URI.parse(url).host
  end

  def validate
    super
    %i(url http_method).each do |attr|
      errors.add(attr, 'cannot be empty') if !send(attr) || send(attr).empty?
    end
  end
end

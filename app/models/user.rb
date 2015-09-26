class User < Sequel::Model
  def validate
    super
    %i(email name password_hash).each do |attr|
      errors.add(attr, 'cannot be empty') if !send(attr) || send(attr).empty?
    end
  end
end

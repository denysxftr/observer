class User < Sequel::Model
  def admin?
    role == 'admin'
  end

  def validate
    super
    %i(email name password_hash).each do |attr|
      errors.add(attr, 'cannot be empty') if !send(attr) || send(attr).empty?
    end
  end

  def password=(pass)
    self.password_hash = Digest::SHA1.hexdigest(pass)
  end
end

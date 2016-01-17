class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :name, type: String
  field :password_hash, type: String
  field :role, type: String, default: 'user'

  def password=(pass)
    self.password_hash = Digest::SHA1.hexdigest(pass)
  end

  def admin?
    role == 'admin'
  end
end

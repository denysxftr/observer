class User
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :projects, index: true

  field :email, type: String
  field :name, type: String
  field :password_hash, type: String
  field :role, type: String, default: 'user'

  validates :role, :password_hash, :name, :email, presence: true

  def password=(pass)
    self.password_hash = Digest::SHA1.hexdigest(pass)
  end

  def admin?
    role == 'admin'
  end
end

class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :servers
  has_many :checks

  field :name, type: String
  field :is_ok, type: Boolean, default: true
end

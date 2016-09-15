class Result
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :check, index: true

  field :is_ok, type: Boolean, default: true
  field :issues, type: Hash, default: {}

  field :timeout, type: Integer
  field :status, type: Integer
  field :ip, type: String

  index(created_at: 1)
end

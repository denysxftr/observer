class Result
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :check, index: true

  field :is_ok, type: Boolean
  field :timeout, type: Integer
  field :status, type: Integer

  index(created_at: 1)
end

class Result
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :check

  field :is_ok, type: Boolean
  field :timeout, type: Integer
  field :status, type: Integer
end

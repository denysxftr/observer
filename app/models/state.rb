class State
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :server

  field :cpu_load, type: Integer
  field :ram_usage, type: Integer
end

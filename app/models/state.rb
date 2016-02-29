class State
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :server

  field :cpu_load, type: Float
  field :ram_usage, type: Float
  field :swap_usage, type: Float
  field :uptime, type: Integer
  field :disks, type: Array
end

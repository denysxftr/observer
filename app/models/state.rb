class State
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :server, index: true

  field :cpu_load, type: Float
  field :ram_usage, type: Float
  field :swap_usage, type: Float
  field :uptime, type: Integer
  field :disks, type: Array

  index(created_at: 1)
end

class LogState
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :server, index: true

  field :cpu_load, type: Float
  field :ram_usage, type: Float
  field :swap_usage, type: Float

  index(created_at: 1)
end

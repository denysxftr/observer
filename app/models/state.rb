class State
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :server

  field :cpu_load, type: Integer
  field :ram_usage, type: Integer
  field :ram_total, type: Integer
end

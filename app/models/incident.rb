class Incident
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :server, index: true

  field :states, type: Array
  field :headline, type: String
  field :description, type: String
end

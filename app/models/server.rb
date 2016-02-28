class Server
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :project

  embeds_many :states

  has_many :incidents

  field :name, type: String
  field :is_ok, type: Boolean, default: true
  field :token, type: String

  before_create :generate_token

  validates :name, presence: true

private

  def generate_token
    self.token = SecureRandom.hex
  end
end

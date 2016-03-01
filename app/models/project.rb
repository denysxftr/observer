class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :servers
  has_many :checks

  has_and_belongs_to_many :users, index: true

  field :name, type: String
  field :is_ok, type: Boolean, default: true

  validates :name, presence: true

  def recalc_state
    if servers.all? { |x| x.is_ok } && checks.all? { |x| x.is_ok }
      update(is_ok: true)
    else
      update(is_ok: false)
    end
  end
end

class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :servers
  has_many :checks

  field :name, type: String
  field :is_ok, type: Boolean, default: true

  validates :name, presence: true

  def recalc_state
    if servers.pluck(:is_ok).all? && checks.pluck(:is_ok).all?
      update(is_ok: true)
    else
      update(is_ok: false)
    end
  end
end

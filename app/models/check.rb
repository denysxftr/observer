class Check
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :results

  belongs_to :project, index: true

  field :name, type: String
  field :is_ok, type: Boolean, default: true
  field :retries, type: Integer, default: 3
  field :expected_ip, type: String
  field :expected_status, type: Integer, default: 200
  field :url, type: String

  field :emails, type: Array, default: []

  validates :name, :url, :retries, presence: true
  validates :retries, numericality: { only_integer: true, greater_than: 0 }
  validates :expected_status, inclusion: { in: STATUS_CODES }, allow_blank: true

  def host
    URI.parse(url).host
  rescue URI::InvalidURIError
    url
  end

  def name_with_project
    if project
      "[#{project.name}] #{name}"
    else
      name
    end
  end

  def first_result
    results.order(:created_at.desc).first
  end
end

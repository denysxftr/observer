class Check
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :results

  belongs_to :project, index: true

  field :name, type: String
  field :is_ok, type: Boolean, default: true
  field :url, type: String

  field :emails, type: Array, default: []

  validates :name, :url, presence: true

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
end

class Check
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :results

  belongs_to :project

  field :name, type: String
  field :is_ok, type: Boolean, default: true
  field :url, type: String

  def host
    URI.parse(url).host
  rescue URI::InvalidURIError
    url
  end
end

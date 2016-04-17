class Server
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :project, index: true

  has_many :states
  has_many :log_states

  has_many :incidents

  field :name, type: String
  field :is_ok, type: Boolean, default: true
  field :token, type: String
  field :problems, type: String

  before_create :generate_token

  validates :name, presence: true

  def current_data
    return @current_data if @current_data
    state = states.last
    @current_data ||= {
      uptime: formatted_uptime(state.uptime),
      cpu: state.cpu_load.round(1),
      ram: state.ram_usage.round(1),
      swap: state.swap_usage.round(1),
      disks: formatted_disks(state.disks)
    }
  end

private

  def formatted_disks(disks)
    disks = disks.select { |disk| !(disk['path'] =~ /^(\/sys|\/run|\/dev)/) }
    disks.map do |disk|
      {
        path: disk['path'],
        usage: disk['used_percent'].round(1),
        total: (disk['total'] / 1073741824.0).round(1),
        free: (disk['free'] / 1073741824.0).round(1)
      }
    end
  end

  def formatted_uptime(seconds)
    seconds = seconds.to_i
    days = seconds / 86400
    hours = (seconds % 86400) / 3600
    minutes = (seconds % 3600) / 60
    sec = seconds % 60
    "#{days}d #{hours}h #{minutes}m #{sec}s"
  end

  def generate_token
    self.token = SecureRandom.hex
  end
end

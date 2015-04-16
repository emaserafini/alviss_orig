class Thermostat < ActiveRecord::Base
  enum mode: [ :inactive, :manual ]

  validates :name, presence: true
  validates :mode, presence: true
  validates :identity_token, presence: true

  has_one :manual_mode, class_name: 'ThermostatMode::Manual'

  after_initialize :set_default_mode, unless: :mode?
  before_validation :generate_identity_token, unless: :identity_token?

  def mode?
    self.mode != nil
  end

  def inactive_mode
    @inactive_mode ||= ThermostatMode::Inactive.new
  end

  def mode_class
    "thermostat_mode/#{mode}".camelize.constantize
  end

  def current_mode
    send "#{mode}_mode"
  end

  def available_modes
    Thermostat.modes.reject { |mode| send("#{mode}_mode").nil? }
  end

  private

  def set_default_mode
    self.mode = :inactive
  end

  def generate_identity_token
    loop do
      self.identity_token = SecureRandom.urlsafe_base64
      break unless Stream.find_by identity_token: identity_token
    end
  end
end

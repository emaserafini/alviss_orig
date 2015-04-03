class Thermostat < ActiveRecord::Base
  enum mode: [ :inactive ]

  validates :name, presence: true
  validates :mode, presence: true
  validates :identity_token, presence: true

  after_initialize :set_default_mode, unless: :mode?
  before_validation :generate_identity_token, unless: :identity_token?

  def mode?
    self.mode != nil
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

class Stream < ActiveRecord::Base
  enum kind: [ :temperature, :status, :log ]

  validates :name, presence: true
  validates :kind, presence: true
  validates :access_token, presence: true
  validates :identity_token, presence: true

  before_validation :generate_identity_token, unless: :identity_token?
  before_validation :generate_access_token, unless: :access_token?

  private

  def generate_identity_token
    self.identity_token = build_token :identity_token, :urlsafe_base64
  end

  def generate_access_token
    self.access_token = build_token :access_token, :hex
  end

  def build_token column, format
    loop do
      token = SecureRandom.send(format)
      break token unless Stream.find_by({ column => token })
    end
  end
end
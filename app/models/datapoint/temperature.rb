class Datapoint::Temperature < ActiveRecord::Base
  belongs_to :stream
  validates :stream, presence: true
  validates :value, numericality: true

  scope :of_stream, -> (stream_id) { where(stream_id: stream_id) }
  scope :latest, -> (num) { order('created_at DESC').limit(num) }

  def self.latest_of_stream stream_id, num
    of_stream(stream_id).latest(num)
  end
end

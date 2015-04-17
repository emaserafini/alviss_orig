class Datapoint::Temperature < ActiveRecord::Base
  belongs_to :stream
  validates :stream, presence: true
  validates :value, numericality: true

  scope :of_stream, -> (stream_id) { where(stream_id: stream_id) }
  scope :latest, -> (num) { order('created_at DESC').limit(num) }
  scope :recent, -> { where('created_at > ?', 5.minutes.ago) }

  def self.latest_of_stream stream_id, num
    of_stream(stream_id).latest(num)
  end

  def self.current_of_stream stream_id
    of_stream(stream_id).recent.last
  end
end

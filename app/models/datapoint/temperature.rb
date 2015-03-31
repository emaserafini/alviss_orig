class Datapoint::Temperature < ActiveRecord::Base
  belongs_to :stream
  validates :stream, presence: true
  validates :value, numericality: true

  scope :of_stream, -> (id) { where(stream_id: id) }
end

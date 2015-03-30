class Datapoint::Temperature < ActiveRecord::Base
  belongs_to :stream
end

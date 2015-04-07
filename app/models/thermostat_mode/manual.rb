class ThermostatMode::Manual < ActiveRecord::Base
  belongs_to :thermostat
  belongs_to :stream_temperature, class_name: 'Stream', foreign_key: 'stream_temperature_id'
end

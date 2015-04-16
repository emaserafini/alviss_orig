FactoryGirl.define do
  factory :manual_mode, class: ThermostatMode::Manual do
    association :thermostat, factory: :thermostat
    association :stream_temperature, factory: :stream, kind: :temperature
    setpoint_temperature 20.1
    program 'heat'
  end
end
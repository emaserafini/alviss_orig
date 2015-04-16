namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    stream = Stream.create name: 'temperature test', kind: :temperature, identity_token: 'K4r4561EySo04TOUMxZEUg', access_token: '275b6b2106d847a55d42af1be73ba7a3'
    thermostat = Thermostat.new name: 'home', identity_token: 'yr2nRRurenVneOqUbtGahQ'
    thermostat.manual_mode = ThermostatMode::Manual.new stream_temperature: stream, setpoint_temperature: 20.1, program: 'heat'
    thermostat.save
  end
end

class CreateThermostatModeManuals < ActiveRecord::Migration
  def change
    create_table :thermostat_mode_manuals do |t|
      t.references :thermostat, index: true
      t.integer :stream_temperature_id, index: true
      t.string :program
      t.float :setpoint_temperature
      t.float :deviation_temperature
      t.integer :minimum_run
      t.datetime :started_at
      t.integer :status

      t.timestamps null: false
    end
    add_foreign_key :thermostat_mode_manuals, :thermostats
  end
end

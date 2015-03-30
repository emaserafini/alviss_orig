class CreateDatapointTemperatures < ActiveRecord::Migration
  def change
    create_table :datapoint_temperatures do |t|
      t.references :stream, index: true
      t.float :value

      t.timestamps null: false
    end
    add_foreign_key :datapoint_temperatures, :streams
  end
end

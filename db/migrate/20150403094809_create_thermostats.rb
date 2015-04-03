class CreateThermostats < ActiveRecord::Migration
  def change
    create_table :thermostats do |t|
      t.string :name
      t.integer :mode
      t.string :identity_token

      t.timestamps null: false
    end

    add_index  :thermostats, :identity_token, unique: true
  end
end

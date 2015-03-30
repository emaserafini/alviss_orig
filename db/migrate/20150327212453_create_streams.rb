class CreateStreams < ActiveRecord::Migration
  def change
    create_table :streams do |t|
      t.string :name
      t.integer :kind
      t.string :identity_token
      t.string :access_token

      t.timestamps null: false
    end

    add_index  :streams, :identity_token, unique: true
    add_index  :streams, :access_token, unique: true
  end
end

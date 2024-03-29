# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150403213539) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "datapoint_temperatures", force: :cascade do |t|
    t.integer  "stream_id"
    t.float    "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "datapoint_temperatures", ["stream_id"], name: "index_datapoint_temperatures_on_stream_id", using: :btree

  create_table "streams", force: :cascade do |t|
    t.string   "name"
    t.integer  "kind"
    t.string   "identity_token"
    t.string   "access_token"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "streams", ["access_token"], name: "index_streams_on_access_token", unique: true, using: :btree
  add_index "streams", ["identity_token"], name: "index_streams_on_identity_token", unique: true, using: :btree

  create_table "thermostat_mode_manuals", force: :cascade do |t|
    t.integer  "thermostat_id"
    t.integer  "stream_temperature_id"
    t.string   "program"
    t.float    "setpoint_temperature"
    t.float    "deviation_temperature"
    t.integer  "minimum_run"
    t.datetime "started_at"
    t.integer  "status"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "thermostat_mode_manuals", ["stream_temperature_id"], name: "index_thermostat_mode_manuals_on_stream_temperature_id", using: :btree
  add_index "thermostat_mode_manuals", ["thermostat_id"], name: "index_thermostat_mode_manuals_on_thermostat_id", using: :btree

  create_table "thermostats", force: :cascade do |t|
    t.string   "name"
    t.integer  "mode"
    t.string   "identity_token"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "thermostats", ["identity_token"], name: "index_thermostats_on_identity_token", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "datapoint_temperatures", "streams"
  add_foreign_key "thermostat_mode_manuals", "thermostats"
end

class CreateWeeklySchedules < ActiveRecord::Migration
  def change
    create_table :weekly_schedules do |t|
      t.json :raw_schedule

      t.timestamps null: false
    end
  end
end

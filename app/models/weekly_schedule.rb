class WeeklySchedule < ActiveRecord::Base

  WEEK_DAYS = {sunday: 0, monday: 1,  tuesday: 2,  wednesday: 3,  thursday: 4,  friday: 5,  saturday: 6}

  class Activity
    attr_accessor :time, :temperature, :status

    def initialize time:, temperature:, status:
      self.time = Tod::TimeOfDay.parse(time)
      self.temperature = temperature.to_f if temperature.is_a? Numeric
      self.status = status.try(:to_sym)
    end

    def self.build args = {}
      self.new args if Tod::TimeOfDay.parsable? args[:time]
    end
  end

  def schedule
    raw_schedule ? raw_schedule_parser : nil
  end

  def raw_schedule_parser
    WEEK_DAYS.map do |dayname, index|
      symbolized_schedule.fetch(dayname, []).map do |symbolized_activity|
        Activity.build symbolized_activity
      end.compact
    end
  end

  def symbolized_schedule
    raw_schedule.try(:deep_symbolize_keys) || {}
  end

  def current_activity
    time = DateTime.now
    activity_for time.wday, time.to_time_of_day
  end

  def activity_for wday, tod
    return nil if schedule.flatten.empty? || !schedule[wday]
    matching_tod = activity_times(wday).select{ |time| time < tod }.last
    if matching_tod
      schedule[wday].find{ |activity| activity.time == matching_tod }
    else
      activity_for wday - 1, Tod::TimeOfDay.new(23,59)
    end
  end

  def activity_times wday
    schedule[wday].map(&:time).sort
  end
end

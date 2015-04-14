class ThermostatMode::Manual < ActiveRecord::Base
  enum status: [ :off, :on, :unknown ]
  AVAILABLE_PROGRAMS = ['heat', 'cool']

  belongs_to :thermostat
  belongs_to :stream_temperature, class_name: 'Stream', foreign_key: 'stream_temperature_id'

  validates :thermostat, presence: true
  validates :stream_temperature, presence: true
  validates :setpoint_temperature, numericality: true
  validates :deviation_temperature, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_run, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :program, inclusion: { in: AVAILABLE_PROGRAMS }

  after_initialize :default_values
  before_update :update_started_at, if: :status_changed?

  def default_values
    self.deviation_temperature ||= 0
    self.minimum_run ||= 0
    self.status ||= :unknown
  end

  def current_temperature reload = nil
    @current_temperature = nil if reload
    @current_temperature ||= current_stream_datapoint.try(:value)
  end

  def setpoint_range
    (setpoint_temperature - deviation_temperature..setpoint_temperature + deviation_temperature)
  end

  def current_status
    return 'unknown' unless current_temperature
    return 'on' unless can_be_turned_off?
    status_from_temperatures
  end

  def can_be_turned_off?
    return true if minimum_run.zero? || !started_at
    Time.now - started_at > minimum_run.minutes
  end

  def check_current_status
    update_attributes status: current_status
    status
  end

  def status_from_temperatures
    if setpoint_range.include? current_temperature
      off? ? 'off' : 'on'
    else
      temperature_program_check ? 'on' : 'off'
    end
  end

  def temperature_program_check
    if heating?
      current_temperature <= setpoint_temperature
    else
      current_temperature >= setpoint_temperature
    end
  end


  private

  def update_started_at
    self.started_at = if status_changed? to: 'on'
      Time.now
    else
      nil
    end
  end

  def heating?
    program == 'heat'
  end

  def current_stream_datapoint
    stream_temperature.current_datapoint
  end
end

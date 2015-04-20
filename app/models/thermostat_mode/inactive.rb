class ThermostatMode::Inactive
  def status
    'off'
  end
  alias :check_current_status :status
end


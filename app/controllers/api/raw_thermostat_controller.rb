module API
  class RawThermostatController < ActionController::Base
    before_action :get_thermostat

    def current_status
      render plain: "#{thermostat.current_status}"
    end

    private


    def thermostat
      @thermostat ||= Thermostat.find_by identity_token: params[:thermostat_identity_token]
    end

    def render_no_record_found
      render nothing: true, status: 404
    end

    def get_thermostat
      thermostat || render_no_record_found
    end
  end
end
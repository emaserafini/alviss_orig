require 'rails_helper'

RSpec.describe API::RawThermostatController, type: :controller do
  let!(:thermostat) { create :thermostat }

  describe '#GET current_status' do
    context 'when thermostat is not present' do
      it 'returns 404 status' do
        get :current_status, { thermostat_identity_token: 4 }
        expect(response.status).to eq 404
      end

      it 'returns nothig' do
        get :current_status, { thermostat_identity_token: 4 }
        expect(response.body).to be_empty
      end
    end

    context 'when thermostat is present' do
      it 'returns 200 status' do
        get :current_status, { thermostat_identity_token: thermostat.identity_token }
        expect(response.status).to eq 200
      end

      %w[on off unknown].each do |status|
        it "returns '#{status}' when #current_status is #{status}" do
          allow_any_instance_of(Thermostat).to receive(:current_status).and_return status
          get :current_status, { thermostat_identity_token: thermostat.identity_token }
          expect(response.body).to eq status
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ThermostatMode::Manual, type: :model do
  context 'validations' do
    it 'require thermostat to be present' do
      expect(subject).to have(1).error_on :thermostat
    end

    it 'require stream_temperature to be present' do
      expect(subject).to have(1).error_on :stream_temperature
    end

    it 'require program to be included in AVAILABLE_PROGRAMS' do
      expect(subject).to have(1).error_on :program
    end

    it 'require setpoint_temperature to be numereric' do
      expect(subject).to have(1).error_on :setpoint_temperature
    end

    it 'pass if all validations are met' do
      subject.thermostat = create :thermostat
      subject.stream_temperature = create :stream, kind: :temperature
      subject.program = 'heat'
      subject.setpoint_temperature = 20.1
      subject.deviation_temperature = 0.6
      subject.minimum_run = 30
      expect(subject).to be_valid
    end
  end

  describe 'before validate' do
    describe 'calls #defaults_value' do
      it 'sets #deviation_temperature to 0 when nil'  do
        subject.valid?
        expect(subject.deviation_temperature).to eq 0
      end

      it 'sets #minimum_run to 0 when nil' do
        subject.valid?
        expect(subject.minimum_run).to eq 0
      end
    end
  end

  describe '#current_temperature' do
    it 'delegate #current_data to Stream' do
      stream = create :stream, kind: :temperature
      subject.stream_temperature = stream
      expect(stream).to receive :current_datapoint
      subject.current_temperature
    end
  end

  describe '#can_be_turned_off?' do
    it 'returns true when #minimum_run is 0' do
      subject.minimum_run = 0
      expect(subject.can_be_turned_off?).to be_truthy
    end

    it 'returns true when #started_at is nil' do
      subject.minimum_run = 2
      subject.started_at = nil
      expect(subject.can_be_turned_off?).to be_truthy
    end

    it 'returns true when is passed at least #minimum_run from #started_at' do
      subject.minimum_run = 5
      subject.started_at = 6.minutes.ago
      expect(subject.can_be_turned_off?).to be_truthy
    end

    it 'returns false when is not passed at least #minimum_run from #started_at' do
      subject.minimum_run = 5
      subject.started_at = 2.minutes.ago
      expect(subject.can_be_turned_off?).to be_falsy
    end
  end

  describe '#current_status' do
    subject { create :manual_mode }

    context 'when #current_temperature is nil' do
      it 'returns unknown' do
        allow(subject).to receive(:current_temperature).and_return nil
        expect(subject.current_status).to eq 'unknown'
      end
    end

    context 'when #can_be_turned_off? is false' do
      it 'returns on' do
        allow(subject).to receive(:current_temperature).and_return 21.1
        allow(subject).to receive(:can_be_turned_off?).and_return false
        expect(subject.current_status).to eq 'on'
      end
    end

    context 'when #can_be_turned_off? is true and #current_temperature is present' do
      it 'calls #status_from_temperatures' do
        expect(subject).to receive(:current_temperature).and_return 21.1
        allow(subject).to receive(:can_be_turned_off?).and_return true
        expect(subject).to receive :status_from_temperatures
        subject.current_status
      end
    end
  end

  describe '#status_from_temperatures' do
    subject { create :manual_mode }

    before { allow(subject).to receive(:current_temperature).and_return 21.1 }

    context 'when current_temperature is included in setpoint_range' do
      before { subject.deviation_temperature = 1 }

      it 'returns on if thermostat is on?' do
        subject.on!
        expect(subject.status_from_temperatures).to eq 'on'
      end

      it 'returns off if thermostat is off?' do
        subject.off!
        expect(subject.status_from_temperatures).to eq 'off'
      end

      it 'returns on if thermostat is unknown?' do
        subject.unknown!
        expect(subject.status_from_temperatures).to eq 'on'
      end
    end

    context 'when program is set to heat' do
      context 'when current_temperature is greater than setpoint_range' do
        it 'returns off' do
          expect(subject.status_from_temperatures).to eq 'off'
        end
      end

      context 'when current_temperature is smaller than setpoint_range' do
        it 'returns on' do
          allow(subject).to receive(:current_temperature).and_return 20
          expect(subject.status_from_temperatures).to eq 'on'
        end
      end
    end

    context 'when program is set to cool' do
      before { subject.program = 'cool' }
      context 'when current_temperature is greater than setpoint_range' do
        it 'returns on' do
          expect(subject.status_from_temperatures).to eq 'on'
        end
      end

      context 'when current_temperature is smaller than setpoint_range' do
        it 'returns off' do
          allow(subject).to receive(:current_temperature).and_return 20
          expect(subject.status_from_temperatures).to eq 'off'
        end
      end
    end
  end

  describe '#check_current_status' do
    subject { create :manual_mode }

    it 'update status running #current_status' do
      allow(subject).to receive(:current_status).and_return 'on'
      subject.check_current_status
      expect(subject.reload).to be_on
    end

    it 'returns #current_status value' do
      allow(subject).to receive(:current_status).and_return 'on'
      expect(subject.current_status).to eq 'on'
    end

    context 'when status changed to :on' do
      %w[off unknown].each do |prev_status|
        it 'started_at being updated' do
          subject.update_attributes status: prev_status
          allow(subject).to receive(:current_status).and_return 'on'
          expect { subject.check_current_status }.to change subject, :started_at
        end
      end
    end

    context 'when status changed to :off or :unknown' do
      %w[off unknown].each do |prev_status|
        it 'started_at being updated with nil' do
          subject.update_attributes status: :on
          allow(subject).to receive(:current_status).and_return prev_status
          expect { subject.check_current_status }.to change(subject, :started_at).to nil
        end
      end
    end

    context 'when status does not changed' do
      %w[off unknown on].each do |prev_status|
        it 'started_at not being updated' do
          subject.update_attributes status: prev_status
          allow(subject).to receive(:current_status).and_return prev_status
          expect { subject.check_current_status }.not_to change subject, :started_at
        end
      end
    end
  end
end

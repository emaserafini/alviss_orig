require 'rails_helper'

RSpec.describe Thermostat, type: :model do
  context 'validations' do
    it 'require name to be present' do
      expect(subject).to have(1).error_on :name
    end

    it 'pass if all validations are met' do
      subject.name = 'asdasd'
      subject.mode = :inactive
      expect(subject).to be_valid
    end
  end

  describe 'on save' do
    context 'when identity_token is nil' do
      it '#generate_identity_token being called' do
        expect(subject).to receive :generate_identity_token
        subject.save
      end
    end

    context 'when identity_token is present' do
      it '#generate_identity_token does not being called' do
        subject.identity_token = 'asd'
        expect(subject).not_to receive :generate_identity_token
        subject.save
      end
    end
  end

  describe 'on initialization' do
    subject { described_class.new }

    context 'when mode is not set' do
      it 'set mode to default calling set_default_mode' do
        expect_any_instance_of(described_class).to receive :set_default_mode
        described_class.new
      end
    end

    context 'when mode is set' do
      it 'does not call set_default_mode' do
        expect_any_instance_of(described_class).not_to receive :set_default_mode
        described_class.new mode: :inactive
      end
    end
  end

  describe '#mode_class' do
    it 'retrurns mode class using mode' do
      subject.mode = :manual
      expect(subject.mode_class).to eq ThermostatMode::Manual
    end
  end

  describe '#available_modes, returns a list of configured modes for thermostat' do
    it 'by default returns an hash that includes "inactive"' do
      expect(subject.available_modes).to include('inactive')
    end

    context 'when manual is configured' do
      subject { create :thermostat, :manual_present, mode: :manual }

      it 'returns an hash that includes "manual"' do
        expect(subject.available_modes).to include('manual')
      end
    end
  end
end

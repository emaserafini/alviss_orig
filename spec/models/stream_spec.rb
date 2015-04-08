require 'rails_helper'

RSpec.describe Stream, type: :model do
  context 'validations' do
    it 'require name to be present' do
      expect(subject).to have(1).error_on :name
    end

    it 'require kind to be present' do
      expect(subject).to have(1).error_on :kind
    end

    it 'pass if all validations are met' do
      subject.name = 'asdasd'
      subject.kind = :temperature
      expect(subject).to be_valid
    end
  end

  describe 'on save' do
    context 'when access_token is nil' do
      it '#generate_access_token being called' do
        expect(subject).to receive :generate_access_token
        subject.save
      end
    end

    context 'when access_token is present' do
      it '#generate_access_token does not being called' do
        subject.access_token = 'asd'
        expect(subject).not_to receive :generate_access_token
        subject.save
      end
    end

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

  context 'upon destroy' do
    subject { create :stream }

    it 'calls delete_datapoints!' do
      expect(subject).to receive(:delete_datapoints!)
      subject.destroy
    end

    it "delete only stream's datapoints" do
      create_list :temperature, 2, stream: subject
      create :temperature
      expect{ subject.destroy }.to change{ subject.datapoint_class.count }.from(3).to(1)
    end
  end

  describe '#datapoint_class' do
    it 'retrurns datapoint class from kind' do
      subject.kind = :temperature
      expect(subject.datapoint_class).to eq Datapoint::Temperature
    end
  end

  describe '#datapoints' do
    let(:fake_datapoint) { double of_stream: nil }
    subject { create :stream }

    before do
      allow(subject).to receive(:datapoint_class).and_return fake_datapoint
    end

    it 'calls #of_stream on datapoint_class' do
      expect(fake_datapoint).to receive(:of_stream)
      subject.datapoints
    end

    it "calls #of_stream passing stream's id" do
      stream_id = subject.id
      expect(fake_datapoint).to receive(:of_stream).with stream_id
      subject.datapoints
    end

    it 'returns datapoints.of_stream value' do
      allow(fake_datapoint).to receive(:of_stream).and_return %w[foo bar]
      expect(subject.datapoints).to eq %w[foo bar]
    end
  end

  describe '#latest_datapoint' do
    let(:fake_datapoint) { double latest_of_stream: nil }
    subject { create :stream }

    before do
      allow(subject).to receive(:datapoint_class).and_return fake_datapoint
    end

    it 'calls #latest_of_stream on datapoint_class' do
      expect(fake_datapoint).to receive(:latest_of_stream)
      subject.latest_datapoint
    end

    it "calls #latest_of_stream passing stream's id an num" do
      stream_id = subject.id
      expect(fake_datapoint).to receive(:latest_of_stream).with stream_id, 1
      subject.latest_datapoint
    end

    it 'returns datapoints.latest_of_stream value' do
      allow(fake_datapoint).to receive(:latest_of_stream).and_return 'datapoint'
      expect(subject.latest_datapoint).to eq 'datapoint'
    end

  end
end

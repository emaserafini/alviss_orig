require 'rails_helper'

RSpec.describe Datapoint::Temperature, type: :model do
  describe 'validations' do
    it 'require stream to be present' do
      expect(subject).to have(1).error_on :stream
    end

    it 'require value to be present' do
      expect(subject).to have(1).error_on :value
    end

    it 'pass when constraints are met' do
      subject.stream = create :stream
      subject.value = 23.5
      expect(subject).to be_valid
    end
  end
end
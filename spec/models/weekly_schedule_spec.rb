require 'rails_helper'

RSpec.describe WeeklySchedule, type: :model do
  let(:valid_raw_schedule) { { :monday => [
                                     { time:  '5:00', temperature: 29, status: 'on' },
                                     { time: '10:30', temperature: 19, status: 'on' }
                                   ],
                              :tuesday => [],
                              :wednesday => [
                                     { time: '10:00', temperature: 23, status: 'on' },
                                     { time: '15:30', temperature: 25, status: 'on' },
                                     { time: '23:00', temperature: 21, status: 'on' }
                                   ],
                              :friday => [
                                     { time: 'error', temperature: 20, status: 'on'}
                                   ]
                            } }

  let(:wednesday) { DateTime.new 2015, 5, 13, 8, 0 }

  describe '#schedule' do
    context 'when raw_schedule is nil' do
      it 'returns nil' do
        expect(subject.schedule).to be_nil
      end
    end

    context 'when raw_schedule is present' do
      before { subject.raw_schedule = {} }
      it 'returns an array' do
        expect(subject.schedule).to be_kind_of Array
      end

      it 'calls raw_schedule_parser' do
        expect(subject).to receive :raw_schedule_parser
        subject.schedule
      end
    end
  end

  describe '#raw_schedule_parser' do
    it 'retrurns an array of 7 element' do
      expect(subject.raw_schedule_parser.size).to eq 7
    end

    context 'when raw_schedule is empty' do
      it 'retrurns and array of 7 empty array' do
        expect(subject.raw_schedule_parser).to eq [[], [], [], [], [], [], []]
      end
    end

    context 'when raw_schedule contain data' do
      it 'returns an array of array that contain Activities' do
        subject.raw_schedule = valid_raw_schedule
        expect(subject.raw_schedule_parser.flatten.map(&:class).uniq.first).to eq WeeklySchedule::Activity
      end
    end
  end

  describe '#current_activity' do
    before do
      allow(DateTime).to receive(:now).and_return(wednesday)
    end

    context 'when schedule is empty' do
      it 'retrurns nil' do
        subject.raw_schedule = {}
        expect(subject.current_activity).to be_nil
      end
    end

    context 'when schedule contains at least one Activity' do
      before { subject.raw_schedule = { :wednesday => [{ time:  '5:00', temperature: 20, status: 'on' }, { time:  '9:00', temperature: 20, status: 'on' }] } }

      it 'calls #activity_for' do
        expect(subject).to receive(:activity_for).with(3, Tod::TimeOfDay.new(8))
        subject.current_activity
      end

      it 'returns an Activity' do
        expect(subject.current_activity).to be_a WeeklySchedule::Activity
      end
    end
  end

  describe '#activity_for' do
    let(:eight_o_clock) { Tod::TimeOfDay.new(8) }

    before do
      allow(DateTime).to receive(:now).and_return(wednesday)
    end

    context 'when schedule is empty' do
      it 'retrurns nil' do
        subject.raw_schedule = {}
        expect(subject.activity_for 1, eight_o_clock).to be_nil
      end
    end

    context 'when schedule contains at least one Activity' do
      it 'returns an Activity' do
        subject.raw_schedule = { :wednesday => [{ time:  '5:00', temperature: 20, status: 'on' }, { time:  '9:00', temperature: 20, status: 'on' }] }
        expect(subject.current_activity).to be_a WeeklySchedule::Activity
      end

      it 'returns the right matching activity' do
        subject.raw_schedule = valid_raw_schedule
        activity = subject.activity_for 1, eight_o_clock
        expect(activity.temperature).to eq 29
        expect(activity.status).to eq :on
        expect(activity.time).to eq Tod::TimeOfDay.new 5
      end
    end
  end

  describe '::Activity' do
    let(:valid_activity_parameters) { { time: '10:00', temperature: 20, status: 'on' } }
    let(:invalid_activity_parameters) { { time: 'error', temperature: 20, status: 'on' } }

    describe 'on initialization' do
      subject { WeeklySchedule::Activity.new(valid_activity_parameters) }

      it 'sets time' do
        expect(subject.time).to eq Tod::TimeOfDay.parse('10:00')
      end

      it 'sets temperature' do
        expect(subject.temperature).to eq 20
      end

      it 'sets status' do
        expect(subject.status).to eq :on
      end

      describe '::build' do
        subject { WeeklySchedule::Activity }
        context 'when time is not parsable with TimeOfDay' do
          it 'returns nil' do
            expect(subject.build(invalid_activity_parameters)).to be_nil
          end
        end

        context 'when time is parsable with TimeOfDay' do
          it 'retrurns Activity' do
            expect(subject.build(valid_activity_parameters)).to be_kind_of subject
          end
        end
      end
    end
  end
end

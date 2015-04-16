FactoryGirl.define do
  factory :thermostat do
    name 'Home thermostat'
  end

  trait :manual_present do
    manual_mode { create :manual_mode }
  end
end

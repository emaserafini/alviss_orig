FactoryGirl.define do
  factory :temperature, class: Datapoint::Temperature do
    association :stream, factory: :stream
    value { rand(-20.0..40.0) }
  end
end

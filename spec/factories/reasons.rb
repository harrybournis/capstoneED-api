FactoryGirl.define do
  factory :reason do
    value { rand 0..10 }
  end
end

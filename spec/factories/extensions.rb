FactoryGirl.define do
  factory :extension do
  	extra_time { 2.days.to_i }
  	association :team, factory: :team
  	association :iteration, factory: :iteration
  end
end

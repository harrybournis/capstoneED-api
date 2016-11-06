FactoryGirl.define do
  factory :section do
  	name { 'Leadership' + (100*rand()).to_s }
  end
end

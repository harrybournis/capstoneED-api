FactoryGirl.define do
  factory :department do
    name				{ "Computer Science#{rand(10000).to_s}" }
    university 	{ "University of #{rand(10000).to_s}" }
  end
end

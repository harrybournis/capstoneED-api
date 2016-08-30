FactoryGirl.define do
  factory :department do
    name				{ "Computer Science#{rand(1000).to_s}" }
    university 	{ "University of #{rand(1000).to_s}" }
  end
end

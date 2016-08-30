FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    logo nil
    enrollment_key { SecureRandom.hex }
    association :project, factory: :project

    factory :team_with_logo do
    	logo "https://robohash.org/sitsequiquia.png?size=300x300"
    end
  end
end

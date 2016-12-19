FactoryGirl.define do
  factory :project do
    sequence(:project_name) { |n| "Team #{n}" }
    sequence(:team_name) { |n| "The xmen#{n}" }
    logo nil
    enrollment_key { SecureRandom.hex }
    association :assignment, factory: :assignment

    factory :project_with_logo do
    	logo "https://robohash.org/sitsequiquia.png?size=300x300"
    end
  end
end

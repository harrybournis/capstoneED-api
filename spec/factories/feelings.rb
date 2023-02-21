FactoryBot.define do
  factory :feeling do
  	sequence(:name) { |n| "Confused#{n}" }
    value { [-1,1].sample }

    factory :feeling_seeder do
      sequence(:name) do |n|
        "#{['Happy', 'Interested', 'Relaxed', 'Satisfied','Positive', 'Strong', 'Angry', 'Confused', 'Depressed', 'Indifferent', 'Sad'].sample} #{n}"
      end
    end
  end
end

FactoryGirl.define do
  factory :students_project, class: JoinTables::StudentsProject do
  	association :project, factory: :project
  	association :student, factory: :student
  	nickname { "wolverine#{rand(100000).to_s}" }

  	after :build do |obj|
  		obj.add_log(JSON.parse({ date_worked: (DateTime.now - 1.day).to_i.to_s, time_worked: 10.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
  	end

    factory :students_project_seeder do
      nickname { [Faker::LordOfTheRings.character, Faker::StarWars.character, Faker::Zelda.character, Faker::HarryPotter.character, "#{Faker::Cat.name} #{Faker::Space.galaxy}"].sample }
    end
	end
end

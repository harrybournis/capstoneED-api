FactoryGirl.define do
  factory :students_project do
    association :project, factory: :project
    association :student, factory: :student
    nickname { "wolverine#{rand(100000).to_s}" }

    factory :students_project_with_points do
      points { rand 0..50 }
    end

    after :build do |obj|
      create :game_setting, assignment: obj.project.assignment unless obj.project.assignment.game_setting
      hours_worked = [1,2,3,4,5,6,7,8,9,10]
      obj.add_log(JSON.parse({ date_worked: (DateTime.now - 1.day).to_i.to_s, time_worked: hours_worked.sample.hours.to_i.to_s, stage: 'Analysis', text: 'Worked on database and use cases' }.to_json))
    end

    factory :students_project_seeder do
      nickname { [Faker::LordOfTheRings.character, Faker::StarWars.character, Faker::Zelda.character, Faker::HarryPotter.character, "#{Faker::Cat.name} #{Faker::Space.galaxy}"].sample + "#{rand(100).to_s}" }
      points { rand 0..50 }
    end
  end
end

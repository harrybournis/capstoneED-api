FactoryGirl.define do
  factory :project do
    sequence(:project_name) { |n| "Project #{n}" }
    sequence(:team_name) { |n| "The xmen#{n}" }
    logo nil
    enrollment_key { SecureRandom.hex }
    description "Lorem ipsum dolor sit amet, pri in erant detracto antiopam."
    association :assignment, factory: :assignment
    unit_id { assignment.unit.id if assignment }
    color do
      gen = ColorGenerator.new saturation: Project::Colorable::COLOR_SATURATION,
                               lightness: Project::Colorable::COLOR_LIGHTNESS
      "##{gen.create_hex}"
    end

    factory :project_with_logo do
      logo "https://robohash.org/sitsequiquia.png?size=300x300"
    end

    factory :project_seeder do
      project_name do
          ["#{Faker::Hacker.verb.capitalize} #{Faker::Hacker.adjective} #{Faker::Pokemon.name} #{Faker::Hacker.noun}",
              "#{Faker::Hacker.adjective.capitalize} #{Faker::Food.ingredient}"].sample
      end
      team_name { Faker::Team.creature.capitalize + " #{1000*rand().to_i}" }
      logo "https://robohash.org/sitsequiquia.png?size=300x300"
      description { Faker::TwinPeaks.quote }
    end
  end
end

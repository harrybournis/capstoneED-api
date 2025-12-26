FactoryBot.define do
  factory :assignment do
    start_date  { Date.today }
    end_date 	{ Date.today + 3.months+(100*rand()) }
    association :lecturer, factory: :lecturer_with_units
    name        { "Assignment #{100*rand().to_i}" }

    transient do
      unit { nil }
    end

    after :build do |a, e|
      a.unit = e.unit if e.unit

      unless a.unit
        a.unit = if a.lecturer&.units&.any?
                   a.lecturer.units.first
                 else
                   a = build(:unit, lecturer: a.lecturer)
                   a.lecturer.units << a
                   a
                 end
      end
    end

    factory :assignment_with_projects do
        after :create do |assignment|
          2.times { assignment.projects << FactoryBot.create(:project, assignment: assignment) }
        end
    end

    factory :assignment_with_settings do
      association :game_setting, factory: :game_setting
    end
  end
end

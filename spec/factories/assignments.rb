FactoryBot.define do
  factory :assignment do
    start_date  { Date.today }
    end_date 	{ Date.today + 3.months+(100*rand()) }
    lecturer    { FactoryBot.create(:lecturer_with_units) }
    unit 		{ lecturer.units.first }
    lecturer_id { lecturer.id }
    unit_id			{ unit.id }
    name        { "Assignment #{100*rand().to_i}" }

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

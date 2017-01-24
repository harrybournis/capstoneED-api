FactoryGirl.define do
  factory :assignment do
    start_date  { Date.today }
    end_date 	{ Date.today + 3.months+(100*rand()) }
    lecturer    { FactoryGirl.create(:lecturer_with_units) }
    unit 		{ lecturer.units.first }
    lecturer_id { lecturer.id }
    unit_id			{ unit.id }
    name        { "Assignment #{100*rand()}" }

    factory :assignment_with_projects do
        after :create do |assignment|
            2.times { assignment.projects << FactoryGirl.create(:project, assignment: assignment) }
        end
    end
  end
end

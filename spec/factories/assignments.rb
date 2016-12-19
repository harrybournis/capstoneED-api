FactoryGirl.define do
  factory :assignment do
    start_date  { Date.today }
    end_date 	  { Date.today + 3.months+(100*rand()) }
    lecturer 		{ FactoryGirl.create(:lecturer_with_units) }
    unit 				{ lecturer.units.first }
    lecturer_id { lecturer.id }
    unit_id			{ unit.id }

    factory :assignment_with_projects do
    	projects { Array.new(2){ |i| FactoryGirl.create(:project) } }
    end
  end
end

FactoryGirl.define do
  factory :project do
    start_date  { Date.today }
    end_date 	  { Faker::Date.forward }
  	description { Faker::Lorem.paragraph }
    lecturer 		{ FactoryGirl.create(:lecturer_with_units) }
    unit 				{ lecturer.units.first }
    lecturer_id { lecturer.id }
    unit_id			{ unit.id }
  end
end

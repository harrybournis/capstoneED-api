FactoryGirl.define do
	factory :iteration do
		name { ['Analysis', 'Design', 'Implementation', 'Testing'].sample }
		start_date { DateTime.now + 1.months + (100*rand()) }
		deadline   { DateTime.now + 1.year + (100*rand()) }
		assignment_id    { FactoryGirl.create(:assignment).id }
	end
end

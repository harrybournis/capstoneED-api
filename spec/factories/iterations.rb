FactoryGirl.define do
	factory :iteration do
		name { ['Analysis', 'Design', 'Implementation', 'Testing'].sample }
		start_date { DateTime.now + 1.months + (100*rand()) }
		deadline   { DateTime.now + 1.year + (100*rand()) }
		project_id    { FactoryGirl.create(:project).id }
	end
end

FactoryBot.define do
	factory :iteration do
		name { ['Analysis', 'Design', 'Implementation', 'Testing'].sample }
    assignment    { FactoryBot.create(:assignment) }
		start_date { assignment ? assignment.start_date : nil }
		deadline   { assignment ? assignment.end_date : nil }
	end
end

FactoryGirl.define do

	factory :project_evaluation do
		user { FactoryGirl.create(:student) }
		project do |obj|
			@now = DateTime.now
			lec = FactoryGirl.create(:lecturer)
			unit = FactoryGirl.create(:unit, lecturer: lec)
			assignment = FactoryGirl.create(:assignment, lecturer: lec, start_date: @now, end_date: @now + 1.month )
			project = FactoryGirl.create(:project, assignment: assignment)
			project.students << user
			project
		end
		iteration { FactoryGirl.create(:iteration, assignment: project.assignment, start_date: @now, deadline: @now + 28.days) }
		association :feeling, factory: :feeling
		percent_complete 20
		date_submitted nil

		factory :project_evaluation_lecturer do
			user { FactoryGirl.create(:lecturer) }
			project do |obj|
				@now = DateTime.now
				unit = FactoryGirl.create(:unit, lecturer: user)
				assignment = FactoryGirl.create(:assignment, lecturer: user, start_date: @now, end_date: @now + 1.month )
				FactoryGirl.create(:project, assignment: assignment)
			end
		end
	end
end

FactoryGirl.define do

	factory :project_evaluation do
		association :user, factory: :student
		association :project, factory: :project
		association :iteration, factory: :iteration
		percent_complete 10
		date_submitted nil

		factory :project_evaluation_student do
			association :user, factory: :student
		end

		factory :project_evaluation_lecturer do
			association :user, factory: :lecturer
		end

		before :create do |obj|
			now = DateTime.now
			obj.iteration.assignment.start_date = now - 1.day
			obj.iteration.assignment.end_date = now + 1.month
			obj.iteration.assignment.save
			obj.project.assignment = obj.iteration.assignment
			obj.iteration.start_date = obj.iteration.assignment.start_date - 1.day + 1.minute
			obj.iteration.deadline = obj.iteration.assignment.end_date - 1.week
			obj.iteration.save
			obj.date_submitted = obj.iteration.deadline - 3.days

			if obj.user.type == 'Student'
				obj.project.students << obj.user
			else
				obj.project.assignment.lecturer = obj.user
			end
		end
	end
end

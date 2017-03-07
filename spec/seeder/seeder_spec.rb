require 'rails_helper'

RSpec.describe "Seeder" do

	before(:each) do
		# 1st Lecturer
		department = FactoryGirl.create(:department_seeder, name: 'Computer Science')
		department2 = FactoryGirl.create(:department_seeder, name: 'English Studies')

		@lecturer1 = FactoryGirl.create(:lecturer_confirmed_seeder, email: 'kostas@bar.com')
		@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
		@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
		@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
		now = DateTime.now
		@assignment = FactoryGirl.create(:assignment, lecturer: @lecturer1, unit: @unit1)
		4.times { FactoryGirl.create(:project_seeder, assignment: @assignment) }
		@iteration1 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now - 40.seconds, deadline: now + 1.second)
		@iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 11.seconds, deadline: now + 1.month)
		@iteration3 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 1.month, deadline: now + 2.months)
		FactoryGirl.create(:pa_form, iteration: @iteration1, start_offset: 2.seconds, end_offset: 1.month)
		FactoryGirl.create(:pa_form, iteration: @iteration2)
		FactoryGirl.create(:pa_form, iteration: @iteration3)
		FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer1.id)

		4.times do |i|
		  5.times do
		    @student = FactoryGirl.create(:student_confirmed_seeder)
		    @student.confirm

		    #@assignment.projects[i].students << @student
		    FactoryGirl.create :students_project_seeder, student: @student, project: @assignment.projects[i]
		  end
		end

		stu = @assignment.projects[0].students[0]
		stu.skip_confirmation_notification!
		stu.update(email: 'giorgos@bar.com')
		stu.confirm

		@assignment.projects.each do |project|
		  project.students.each do |student|
		    FactoryGirl.create(:project_evaluation_seeder, user: student, project: project, iteration: @iteration1, date_submitted: now)
		  end
		end

		@assignment.projects.each do |project|
		  FactoryGirl.create(:project_evaluation_seeder, user: @lecturer1, project: project, iteration: @iteration1, date_submitted: now)
		end



		# 2nd Lecturer
		@lecturer2 = FactoryGirl.create(:lecturer_confirmed_seeder, email: 'foo1@bar.com')
		@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
		@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
		@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
		now = DateTime.now
		@assignment = FactoryGirl.create(:assignment, lecturer: @lecturer2, unit: @unit1)
		4.times { FactoryGirl.create(:project_seeder, assignment: @assignment) }
		@iteration1 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now - 40.seconds, deadline: now + 1.second)
		@iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 11.seconds, deadline: now + 1.month)
		@iteration3 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 1.month, deadline: now + 2.months)
		FactoryGirl.create(:pa_form, iteration: @iteration1, start_offset: 2.seconds, end_offset: 1.month)
		FactoryGirl.create(:pa_form, iteration: @iteration2)
		FactoryGirl.create(:pa_form, iteration: @iteration3)
		FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer2.id)
		FactoryGirl.create(:question, lecturer_id: @lecturer2.id)

		4.times do |i|
		  5.times do
		    @student = FactoryGirl.create(:student_confirmed_seeder)
		    @student.confirm

		    #@assignment.projects[i].students << @student
		    FactoryGirl.create :students_project_seeder, student: @student, project: @assignment.projects[i]
		  end
		end

		@assignment.projects.each do |project|
		  project.students.each do |student|
		    FactoryGirl.create(:project_evaluation_seeder, user: student, project: project, iteration: @iteration1, date_submitted: now)
		  end
		end

		@assignment.projects.each do |project|
		  FactoryGirl.create(:project_evaluation_seeder, user: @lecturer2, project: project, iteration: @iteration1, date_submitted: now)
		end

	end


	it 'works' do
		expect(Lecturer.count).to eq 2
		lecturer1 = Lecturer.first
		expect(lecturer1.email).to eq('kostas@bar.com')
		expect(lecturer1.valid_password?('12345678')).to be_truthy

		expect(@lecturer1.units.count).to eq 3
		expect(@lecturer1.assignments.count).to eq 1
		expect(@lecturer1.assignments[0].iterations.count).to eq 3
		expect(@lecturer1.questions.count).to eq 8
		expect(@lecturer1.projects.count).to eq 4

		expect(@lecturer2.units.count).to eq 3
		expect(@lecturer2.assignments.count).to eq 1
		expect(@lecturer2.assignments[0].iterations.count).to eq 3
		expect(@lecturer2.questions.count).to eq 8
		expect(@lecturer2.projects.count).to eq 4
		expect(Student.count).to eq 40
		expect(Project.all.sample.students.count).to eq 5
		expect(Project.last.project_evaluations.count).to eq 6

		# pa forms
		Timecop.travel 1.day do
			expect(Student.find_by(email: 'giorgos@bar.com').projects.first.iterations.first.pa_form.active?).to be_truthy
		end
 	end

end

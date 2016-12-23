# 1st Lecturer
department = FactoryGirl.create(:department, name: 'Computer Science')
department2 = FactoryGirl.create(:department, name: 'English Studies')

@lecturer1 = FactoryGirl.build(:lecturer_with_password, email: 'kostas@bar.com').process_new_record
@lecturer1.skip_confirmation_notification!
@lecturer1.save
@lecturer1.confirm
@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
now = DateTime.now
@assignment = FactoryGirl.create(:assignment, lecturer: @lecturer1, unit: @unit1)
4.times { FactoryGirl.create(:project, assignment_id: @assignment.id) }
@iteration1 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now, deadline: now + 1.month)
@iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 1.month, deadline: now + 2.months)
@iteration3 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 2.month, deadline: now + 3.months)
FactoryGirl.create(:pa_form, iteration: @iteration1)
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
		@student = FactoryGirl.build(:student)
		@student.skip_confirmation_notification!
		@student.save
		@student.confirm

		@assignment.projects[i].students << @student
	end
end

@assignment.projects.each do |project|
	project.students.each do |student|
		FactoryGirl.create(:project_evaluation, user: student, project: project, iteration: @iteration1, date_submitted: DateTime.now + rand(5..12).days)
	end
end

@assignment.projects.each do |project|
	FactoryGirl.create(:project_evaluation, user: @lecturer1, project: project, iteration: @iteration1, date_submitted: DateTime.now + rand(5..12).days)
end



# 2nd Lecturer
@lecturer2 = FactoryGirl.build(:lecturer_with_password, email: 'foo1@bar.com').process_new_record
@lecturer2.skip_confirmation_notification!
@lecturer2.save
@lecturer2.confirm
@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer2, department: department)
now = DateTime.now
@assignment = FactoryGirl.create(:assignment, lecturer: @lecturer2, unit: @unit1)
4.times { FactoryGirl.create(:project, assignment_id: @assignment.id) }
@iteration1 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now, deadline: now + 1.month)
@iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 1.month, deadline: now + 2.months)
@iteration3 = FactoryGirl.create(:iteration, assignment_id: @assignment.id, start_date: now + 2.month, deadline: now + 3.months)
FactoryGirl.create(:pa_form, iteration: @iteration1)
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
		@student = FactoryGirl.build(:student)
		@student.skip_confirmation_notification!
		@student.save
		@student.confirm

		@assignment.projects[i].students << @student
	end
end

@assignment.projects.each do |project|
	project.students.each do |student|
		FactoryGirl.create(:project_evaluation, user: student, project: project, iteration: @iteration1, date_submitted: DateTime.now + rand(5..12).days)
	end
end

@assignment.projects.each do |project|
	FactoryGirl.create(:project_evaluation, user: @lecturer2, project: project, iteration: @iteration1, date_submitted: DateTime.now + rand(5..12).days)
end

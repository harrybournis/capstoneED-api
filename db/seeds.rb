# 1st Lecturer
department = FactoryGirl.create(:department, name: 'Computer Science')
department2 = FactoryGirl.create(:department, name: 'English Studies')

@lecturer1 = FactoryGirl.build(:lecturer_with_password, email: 'foo1@bar.com').process_new_record
@lecturer1.skip_confirmation_notification!
@lecturer1.save
@lecturer1.confirm
@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@project1 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit1)
@project2 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit2)
@project3 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit3)
4.times { FactoryGirl.create(:team, project_id: @project1.id) }
3.times { FactoryGirl.create(:team, project_id: @project2.id) }
4.times { FactoryGirl.create(:team, project_id: @project3.id) }
FactoryGirl.create(:iteration, project_id: @project1.id)
FactoryGirl.create(:iteration, project_id: @project2.id)
FactoryGirl.create(:iteration, project_id: @project2.id)
FactoryGirl.create(:iteration, project_id: @project3.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)

@student = FactoryGirl.build(:student_with_password, email: 'kostas@bar.com').process_new_record
@student.skip_confirmation_notification!
@student.save
@student.confirm

@project1.teams.sample.students << @student
@project2.teams.sample.students << @student
@project3.teams.sample.students << @student

29.times do
	@student = FactoryGirl.build(:student_with_password).process_new_record
	@student.skip_confirmation_notification!
	@student.save
	@student.confirm

	@project1.teams.sample.students << @student
	@project2.teams.sample.students << @student
	@project3.teams.sample.students << @student
end

# 2nd Lecturer
@lecturer1 = FactoryGirl.build(:lecturer_with_password, email: 'foo2@bar.com').process_new_record
@lecturer1.skip_confirmation_notification!
@lecturer1.save
@lecturer1.confirm
@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@project1 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit1)
@project2 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit2)
@project3 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit3)
4.times { FactoryGirl.create(:team, project_id: @project1.id) }
3.times { FactoryGirl.create(:team, project_id: @project2.id) }
4.times { FactoryGirl.create(:team, project_id: @project3.id) }
FactoryGirl.create(:iteration, project_id: @project1.id)
FactoryGirl.create(:iteration, project_id: @project2.id)
FactoryGirl.create(:iteration, project_id: @project2.id)
FactoryGirl.create(:iteration, project_id: @project3.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)

Student.all.each do |student|
	@project1.teams.sample.students << student
	@project2.teams.sample.students << student
	@project3.teams.sample.students << student
end

# 3rd Lecturer
@lecturer1 = FactoryGirl.build(:lecturer_with_password, email: 'foo3@bar.com').process_new_record
@lecturer1.skip_confirmation_notification!
@lecturer1.save
@lecturer1.confirm
@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
@project1 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit1)
@project2 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit2)
@project3 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit3)
4.times { FactoryGirl.create(:team, project_id: @project1.id) }
3.times { FactoryGirl.create(:team, project_id: @project2.id) }
4.times { FactoryGirl.create(:team, project_id: @project3.id) }
FactoryGirl.create(:iteration, project_id: @project1.id)
FactoryGirl.create(:iteration, project_id: @project2.id)
FactoryGirl.create(:iteration, project_id: @project2.id)
FactoryGirl.create(:iteration, project_id: @project3.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
FactoryGirl.create(:question, lecturer_id: @lecturer1.id)

Student.all.each do |student|
	@project1.teams.sample.students << student
	@project2.teams.sample.students << student
	@project3.teams.sample.students << student
end


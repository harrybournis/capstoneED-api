require 'rails_helper'

RSpec.describe "Seeder" do

	# before(:each) do
	# 	# 1st Lecturer
	# 	department = FactoryGirl.create(:department, name: 'Computer Science')
	# 	department2 = FactoryGirl.create(:department, name: 'English Studies')

	# 	@lecturer1 = FactoryGirl.build(:lecturer_with_password).process_new_record
	# 	@lecturer1.save
	# 	@lecturer1.confirm
	# 	@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
	# 	@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
	# 	@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
	# 	@project1 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit1)
	# 	@project2 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit2)
	# 	@project3 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit3)
	# 	4.times { FactoryGirl.create(:team, project_id: @project1.id) }
	# 	3.times { FactoryGirl.create(:team, project_id: @project2.id) }
	# 	4.times { FactoryGirl.create(:team, project_id: @project3.id) }
	# 	FactoryGirl.create(:iteration, project_id: @project1.id)
	# 	FactoryGirl.create(:iteration, project_id: @project2.id)
	# 	FactoryGirl.create(:iteration, project_id: @project2.id)
	# 	FactoryGirl.create(:iteration, project_id: @project3.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)

	# 	30.times do
	# 		@student = FactoryGirl.create(:student_with_password).process_new_record
	# 		@student.save
	# 		@student.confirm

	# 		@project1.teams.sample.students << @student
	# 		@project2.teams.sample.students << @student
	# 		@project3.teams.sample.students << @student
	# 	end

	# 	# 2nd Lecturer
	# 	@lecturer1 = FactoryGirl.build(:lecturer_with_password).process_new_record
	# 	@lecturer1.save
	# 	@lecturer1.confirm
	# 	@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
	# 	@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
	# 	@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
	# 	@project1 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit1)
	# 	@project2 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit2)
	# 	@project3 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit3)
	# 	4.times { FactoryGirl.create(:team, project_id: @project1.id) }
	# 	3.times { FactoryGirl.create(:team, project_id: @project2.id) }
	# 	4.times { FactoryGirl.create(:team, project_id: @project3.id) }
	# 	FactoryGirl.create(:iteration, project_id: @project1.id)
	# 	FactoryGirl.create(:iteration, project_id: @project2.id)
	# 	FactoryGirl.create(:iteration, project_id: @project2.id)
	# 	FactoryGirl.create(:iteration, project_id: @project3.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)

	# 	Student.all.each do |student|
	# 		@project1.teams.sample.students << student
	# 		@project2.teams.sample.students << student
	# 		@project3.teams.sample.students << student
	# 	end

	# 	# 3rd Lecturer
	# 	@lecturer1 = FactoryGirl.build(:lecturer_with_password).process_new_record
	# 	@lecturer1.save
	# 	@lecturer1.confirm
	# 	@unit1 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
	# 	@unit2 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
	# 	@unit3 = FactoryGirl.create(:unit, lecturer: @lecturer1, department: department)
	# 	@project1 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit1)
	# 	@project2 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit2)
	# 	@project3 = FactoryGirl.create(:project, lecturer: @lecturer1, unit: @unit3)
	# 	4.times { FactoryGirl.create(:team, project_id: @project1.id) }
	# 	3.times { FactoryGirl.create(:team, project_id: @project2.id) }
	# 	4.times { FactoryGirl.create(:team, project_id: @project3.id) }
	# 	FactoryGirl.create(:iteration, project_id: @project1.id)
	# 	FactoryGirl.create(:iteration, project_id: @project2.id)
	# 	FactoryGirl.create(:iteration, project_id: @project2.id)
	# 	FactoryGirl.create(:iteration, project_id: @project3.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)
	# 	FactoryGirl.create(:question, lecturer_id: @lecturer1.id)

	# 	Student.all.each do |student|
	# 		@project1.teams.sample.students << student
	# 		@project2.teams.sample.students << student
	# 		@project3.teams.sample.students << student
	# 	end
	# end

	# it 'works' do
	# 	expect(Lecturer.count).to eq(3)
	# 	expect(@lecturer1.units.count).to eq(3)
	# 	expect(@lecturer1.projects.count).to eq(3)
	# 	expect(@lecturer1.projects[0].iterations.count).to eq(1)
	# 	expect(@lecturer1.questions.count).to eq(8)
	# 	expect(@lecturer1.teams.count).to eq(11)
	# 	expect(Student.count).to eq(30)
	# 	expect(@project1.students.count).to eq(30)
	# 	expect(Student.first.teams.count).to eq(9)
 # 	end

end

require 'rails_helper'

RSpec.describe JoinTables::StudentsProject, type: :model do

	subject { FactoryGirl.build :students_project }

	it { should belong_to :project }
	it { should belong_to :student }

	it 'should validate that the student is not already part of the Project in a different team' do
		student = FactoryGirl.create(:student)
		assignment = FactoryGirl.create(:assignment_with_projects)
		assignment.projects.first.students << student

		students_project = JoinTables::StudentsProject.new(student_id: student.id, project_id: assignment.projects.last.id)
		expect(students_project.valid?).to be_falsy
		expect(students_project.errors[:student_id].first).to eq('has already enroled in a different Project for this Assignment')
	end

	it 'validates uniqueness of nickname for project' do
		student = FactoryGirl.create(:student)
		student_other = FactoryGirl.create(:student)
		student_third = FactoryGirl.create(:student)
		assignment = FactoryGirl.create(:assignment_with_projects)
		project = assignment.projects.first
		project_other = assignment.projects.last

		sp1 = JoinTables::StudentsProject.new(nickname: 'methodman', student_id: student.id, project_id: project.id)
		sp2 = JoinTables::StudentsProject.new(nickname: 'methodman', student_id: student_other.id, project_id: project.id)
		sp3 = JoinTables::StudentsProject.new(nickname: 'methodman', student_id: student_other.id, project_id: project_other.id)
		sp4 = JoinTables::StudentsProject.new(nickname: 'methodman', student_id: student_third.id, project_id: project_other.id)

		expect(sp1.save).to be_truthy
		expect(sp2.save).to be_falsy
		expect(sp2.errors[:nickname][0]).to include('already been taken')
		expect(sp3.save).to be_truthy
		expect(sp4.save).to be_falsy
		expect(sp2.errors[:nickname][0]).to include('already been taken')
	end
end

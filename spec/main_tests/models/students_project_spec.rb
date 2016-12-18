require 'rails_helper'

RSpec.describe JoinTables::StudentsProject, type: :model do

	subject { JoinTables::StudentsProject.create(student_id: FactoryGirl.create(:student).id, project_id: FactoryGirl.create(:project).id) }

	it { should belong_to(:project) }
	it { should belong_to(:student) }

	it 'should validate that the student is not already part of the Project in a different team' do
		student = FactoryGirl.create(:student)
		assignment = FactoryGirl.create(:assignment_with_projects)
		assignment.projects.first.students << student

		students_project = JoinTables::StudentsProject.new(student_id: student.id, project_id: assignment.projects.last.id)
		expect(students_project.valid?).to be_falsy
		expect(students_project.errors[:student_id].first).to eq('has already enroled in a different Project for this Assignment')
	end
end

require 'rails_helper'

RSpec.describe JoinTables::StudentsTeam, type: :model do

	subject { JoinTables::StudentsTeam.create(student_id: FactoryGirl.create(:student).id, team_id: FactoryGirl.create(:team).id) }

	it { should belong_to(:team) }
	it { should belong_to(:student) }

	it 'should validate that the student is not already part of the Project in a different team' do
		student = FactoryGirl.create(:student)
		project = FactoryGirl.create(:project_with_teams)
		project.teams.first.students << student

		students_team = JoinTables::StudentsTeam.new(student_id: student.id, team_id: project.teams.last.id)
		expect(students_team.valid?).to be_falsy
		expect(students_team.errors[:student_id].first).to eq('has already enroled in a different team for this Project')
	end
end

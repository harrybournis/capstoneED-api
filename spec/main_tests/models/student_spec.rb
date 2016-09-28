require 'rails_helper'

RSpec.describe Student, type: :model do

	describe 'validations' do
		subject(:student) { FactoryGirl.build(:student) }

		it { should have_many(:teams).through(:students_teams) }
		it { should have_many(:projects).through(:teams) }
		it { should have_many(:peer_assessments_submitted_by) }
		it { should have_many(:peer_assessments_submitted_for) }

		it { should validate_presence_of(:first_name) }
		it { should validate_presence_of(:last_name) }
		it { should validate_presence_of(:email) }

		it { should validate_absence_of :position }
		it { should validate_absence_of :university }

		it { should validate_uniqueness_of(:id) }
		it { should validate_uniqueness_of(:email).case_insensitive }

		it { should validate_confirmation_of(:password) }

		it 'does not allow provider to be updated' do
			student = FactoryGirl.create(:student)
			expect(student.update(provider: 'email')).to be_truthy
			expect(student.errors).to be_empty
			expect(student.provider).to eq('test')
		end
	end

	let(:student) { FactoryGirl.create(:student) }

	it 'destroys students_teams on destroy' do
		project = FactoryGirl.create(:project_with_teams)
		@team = project.teams.first
		student = FactoryGirl.create(:student)
		@team.students << student
		team_count = Team.all.size
		expect(JoinTables::StudentsTeam.all.count).to eq(1)
		expect { student.destroy }.to change { JoinTables::StudentsTeam.all.count }.by(-1)
		expect(Team.all.size).to eq(team_count)
	end

	it '#teammates returns students in the same teams' do
		@user = FactoryGirl.create(:student_confirmed)

		team1 = FactoryGirl.create(:team)
		team2 = FactoryGirl.create(:team)
		team3 = FactoryGirl.create(:team)
		teammate = FactoryGirl.create(:student_confirmed)
		3.times { team1.students << FactoryGirl.create(:student_confirmed) }
		team1.students << @user
		team1.students << teammate
		3.times { team2.students << FactoryGirl.create(:student_confirmed) }
		3.times { team3.students << FactoryGirl.create(:student_confirmed) }
		team3.students << @user
		team3.students << teammate

		expect(@user.teams.length).to eq 2
		expect(@user.teammates.length).to eq 7
	end
end

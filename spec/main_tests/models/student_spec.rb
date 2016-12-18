require 'rails_helper'

RSpec.describe Student, type: :model do

	describe 'validations' do
		subject(:student) { FactoryGirl.build(:student) }

		it { should have_many(:projects).through(:students_projects) }
		it { should have_many(:assignments).through(:projects) }
		it { should have_many(:peer_assessments_submitted_by) }
		it { should have_many(:peer_assessments_submitted_for) }

		it { should validate_presence_of(:first_name) }
		it { should validate_presence_of(:last_name) }
		it { should validate_presence_of(:email) }
		it { should validate_presence_of :nickname }

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

	it 'destroys students_projects on destroy' do
		assignment = FactoryGirl.create(:assignment_with_projects)
		@project = assignment.projects.first
		student = FactoryGirl.create(:student)
		@project.students << student
		team_count = Project.all.size
		expect(JoinTables::StudentsProject.all.count).to eq(1)
		expect { student.destroy }.to change { JoinTables::StudentsProject.all.count }.by(-1)
		expect(Project.all.size).to eq(team_count)
	end

	it '#teammates returns students in the same projects' do
		@user = FactoryGirl.create(:student_confirmed)

		project1 = FactoryGirl.create(:project)
		project2 = FactoryGirl.create(:project)
		project3 = FactoryGirl.create(:project)
		teammate = FactoryGirl.create(:student_confirmed)
		3.times { project1.students << FactoryGirl.create(:student_confirmed) }
		project1.students << @user
		project1.students << teammate
		3.times { project2.students << FactoryGirl.create(:student_confirmed) }
		3.times { project3.students << FactoryGirl.create(:student_confirmed) }
		project3.students << @user
		project3.students << teammate

		expect(@user.projects.length).to eq 2
		expect(@user.teammates.length).to eq 7
	end
end

require 'rails_helper'

RSpec.describe Project, type: :model do

		describe 'validations' do
			subject(:project) { FactoryGirl.build(:project) }

			it { should have_many(:students).through(:students_projects).dependent(:delete_all) }
			it { should have_many(:students_projects) }
			it { should have_many(:iterations).through(:assignment) }
			it { should belong_to(:assignment) }
			it { should have_one(:lecturer).through(:assignment) }
			it { should have_one :extension }
			it { should have_many :project_evaluations }

			it { should validate_presence_of :project_name }
			it { should validate_presence_of :assignment }
			it { should validate_presence_of :team_name }
			it { should validate_presence_of :description }

			it { should validate_uniqueness_of(:id) }
			it { should validate_uniqueness_of(:enrollment_key) }
			it { should validate_uniqueness_of(:project_name).scoped_to(:assignment_id).case_insensitive }

			it 'destroys StudentTeams on destroy' do
				assignment = FactoryGirl.create(:assignment_with_projects)
				@project = assignment.projects.first
				2.times { @project.students << FactoryGirl.create(:student) }
				students_count = Student.all.size
				expect(JoinTables::StudentsProject.all.count).to eq(2)
				expect { Project.destroy(@project.id) }.to change { JoinTables::StudentsProject.all.count }.by(-2)
				expect(Student.all.size).to eq(students_count)
			end

			it 'autogenerates enrollment key if not provided by user' do
				assignment = FactoryGirl.create(:assignment)
				attributes = FactoryGirl.attributes_for(:project).except(:enrollment_key).merge(assignment_id: assignment.id)
				project = Project.new(attributes)
				project.valid?
				expect(project.errors[:enrollment_key]).to be_empty
				expect(project.save).to be_truthy
				project = Project.create(FactoryGirl.attributes_for(:project).except(:enrollment_key).merge(assignment_id: assignment.id))
				expect(project).to be_truthy
			end

			it 'does not autogenerate key if provided' do
				assignment = FactoryGirl.create(:assignment)
				attributes = FactoryGirl.attributes_for(:project).merge(assignment_id: assignment.id, enrollment_key: 'key')
				project = Project.new(attributes)
				project.valid?
				expect(project.errors[:enrollment_key]).to be_empty
				expect(project.enrollment_key).to eq('key')
			end

			it 'project_health returns the mean of the iterations_health' do
				assignment = FactoryGirl.create(:assignment)
				2.times { assignment.iterations << FactoryGirl.create(:iteration) }
				project = FactoryGirl.create(:project)
				assignment.projects << project

				iteration1_health = assignment.iterations[0].iteration_health
				iteration2_health = assignment.iterations[1].iteration_health
				expected_health = ((iteration1_health + iteration2_health) / 2).round

				expect(project.project_health).to eq(expected_health)
			end
	end
end

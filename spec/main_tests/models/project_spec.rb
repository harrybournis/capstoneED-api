require 'rails_helper'

RSpec.describe Project, type: :model do

		describe 'validations' do
			subject(:project) { FactoryGirl.build(:project) }

			it { should have_many(:students).through(:students_projects).dependent(:delete_all) }
			it { should have_many(:students_projects) }
			it { should belong_to(:assignment) }
			it { should have_one(:lecturer).through(:assignment) }
			it { should have_one :extension }

			it { should validate_presence_of(:name) }
			it { should validate_presence_of(:assignment) }

			it { should validate_uniqueness_of(:id) }
			it { should validate_uniqueness_of(:enrollment_key) }
			it { should validate_uniqueness_of(:name).scoped_to(:assignment_id).case_insensitive }

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
	end
end

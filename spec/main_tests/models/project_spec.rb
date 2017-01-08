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
			it { should have_many :peer_assessments }

			it { should validate_presence_of :project_name }
			it { should validate_presence_of :assignment }
			it { should validate_presence_of :description }

			it { should validate_uniqueness_of(:id) }
			it { should validate_uniqueness_of(:enrollment_key) }
			it { should validate_uniqueness_of(:project_name).scoped_to(:assignment_id).case_insensitive }

			it 'vaidates uniqueness of team_name for assignment' do
				project = build :project
				expect(project.save).to be_truthy

				# different assignment, same team_name. should be correct
				project2 = build :project, team_name: project.team_name
				expect(project2.save).to be_truthy

				# same assignment, same team_name, should be false
				project3 = build :project, assignment: project.assignment, team_name: project.team_name
				expect(project3.save).to be_falsy
				expect(project3.errors[:team_name][0]).to include('taken')

				# same assignment, same team_name all capitals, should be false
				project4 = build :project, assignment: project.assignment, team_name: project.team_name.upcase
				expect(project4.save).to be_falsy
				expect(project4.errors[:team_name][0]).to include('taken')
			end

			it 'validates presence of team_name' do
				project = create :project
				expect(project.save).to be_truthy

				project.team_name = nil
				expect(project.save).to be_falsy
				expect(project.errors[:team_name][0]).to eq "can't be blank"
			end

			it 'destroys StudentTeams on destroy' do
				assignment = FactoryGirl.create(:assignment_with_projects)
				@project = assignment.projects.first
				2.times { create :students_project, student: create(:student), project: @project }#@project.students << FactoryGirl.create(:student) }
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

			it '#student_members returns TeamMember objects with nickname' do
				assignment = FactoryGirl.create(:assignment)
				project = FactoryGirl.create(:project, assignment: assignment)
				student1 = FactoryGirl.create(:student)
				student2 = FactoryGirl.create(:student)

				create :students_project, student: student1, project: project
				create :students_project, student: student2, project: project
				student_members = project.student_members

				student_members.each do |student|
					if student.id == student1.id
						expect(student.email).to eq(student1.email)
						expect(student.nickname).to eq(student1.nickname_for_project_id(project.id))
					end
				end
				project.reload
				expect(student_members.length).to eq(project.students.length)
			end

			describe 'autogenerates team_name' do
				it 'if none was given during creation' do
					assignment = create :assignment
					attributes = attributes_for(:project).except(:team_name).merge!(assignment_id: assignment.id)
					expect(attributes[:team_name]).to be_falsy

					project = Project.new(attributes)

					expect(project.save).to be_truthy
					expect(project.team_name).to eq("Team 1")
				end

				it 'assigns the number of the projects in the Assignment' do
					# create first project, which will be called 'Team 1'
					assignment = create :assignment
					attributes = attributes_for(:project).except(:team_name).merge!(assignment_id: assignment.id)

					project = Project.new(attributes)

					expect(project.save).to be_truthy
					expect(assignment.projects.count).to eq(1)
					expect(project.team_name).to eq("Team 1")

					# create second project, which will be called 'Team 2'
					attributes = attributes_for(:project).except(:team_name).merge!(assignment_id: assignment.id)

					project = Project.new(attributes)

					expect(project.save).to be_truthy
					expect(assignment.projects.count).to eq(2)
					expect(project.team_name).to eq("Team 2")

					# create third project, which will be called 'Team 3'
					assignment.reload
					attributes = attributes_for(:project).except(:team_name).merge!(assignment_id: assignment.id)

					project = Project.new(attributes)

					expect(project.save).to be_truthy
					expect(assignment.projects.count).to eq(3)
					expect(project.team_name).to eq("Team 3")
				end
			end

	end
end

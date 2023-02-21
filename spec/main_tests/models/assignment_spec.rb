require 'rails_helper'

RSpec.describe Assignment, type: :model do

		describe 'validations' do
			subject(:assignment) { FactoryBot.build(:assignment) }

			it { should belong_to(:lecturer) }
			it { should belong_to(:unit) }
			it { should have_many(:projects).dependent(:destroy) }
			it { should have_many(:students_projects).through(:projects) }
			it { should have_many(:students).through(:students_projects) }
			it { should have_many(:iterations).dependent :destroy }
			it { should have_many(:pa_forms).through(:iterations) }

			it { should validate_presence_of(:start_date) }
			it { should validate_presence_of(:end_date) }
			it { should validate_presence_of(:unit_id) }
			it { should validate_presence_of(:lecturer_id) }
			it { should validate_presence_of(:name) }

			it { should validate_uniqueness_of(:id) }

			it '.active returns only active assignments' do
				assignment1 = create :assignment, start_date: Date.today - 3.days, end_date: Date.today + 1.month
				assignment2 = create :assignment, start_date: Date.today + 1.year, end_date: Date.today + 2.years

				expect(Assignment.count).to eq(2)
				expect(Assignment.active.count).to eq(1)
				expect(Assignment.active.first).to eq assignment1
			end

			it 'should validate that unit_id belongs to lecturer_id' do
				assignment.unit = FactoryBot.create(:unit)
				expect(assignment.lecturer.units).to_not include(assignment.unit)
				expect(assignment.valid?).to be_falsy
				expect(assignment.errors[:unit].first).to eq("does not belong in the Lecturer's list of Units")

				assignment.lecturer.units << assignment.unit
				expect(assignment.lecturer.units).to include(assignment.unit)
				expect(assignment.valid?).to be_truthy
			end

			it 'desroying a assignment should destroy its all projects' do
				assignment = FactoryBot.create(:assignment_with_projects)
				expect(assignment.projects.length).to eq(2)
				expect {
					assignment.destroy
				}.to change { Project.all.count }.by(-2)
			end

			it 'project_counter returns the number of projects if persisted, or returns 0' do
				assignment = create :assignment
				expect(assignment.projects.count).to eq(0)
				expect(assignment.project_counter).to eq(0)

				project = create :project, assignment: assignment
				assignment.reload
				expect(assignment.project_counter).to eq(1)

				assignment = build :assignment
				expect(assignment.project_counter).to eq(0)
			end
	end
end

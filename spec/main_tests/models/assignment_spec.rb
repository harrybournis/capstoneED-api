require 'rails_helper'

RSpec.describe Assignment, type: :model do

		describe 'validations' do
			subject(:assignment) { FactoryGirl.build(:assignment) }

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

			it 'should validate that unit_id belongs to lecturer_id' do
				assignment.unit = FactoryGirl.create(:unit)
				expect(assignment.lecturer.units).to_not include(assignment.unit)
				expect(assignment.valid?).to be_falsy
				expect(assignment.errors[:unit].first).to eq("does not belong in the Lecturer's list of Units")

				assignment.lecturer.units << assignment.unit
				expect(assignment.lecturer.units).to include(assignment.unit)
				expect(assignment.valid?).to be_truthy
			end

			it 'desroying a assignment should destroy its all projects' do
				assignment = FactoryGirl.create(:assignment_with_projects)
				expect(assignment.projects.length).to eq(2)
				expect {
					assignment.destroy
				}.to change { Project.all.count }.by(-2)
			end
	end
end

require 'rails_helper'

RSpec.describe Project, type: :model do

		describe 'validations' do
			subject(:project) { FactoryGirl.build(:project) }

			it { should belong_to(:lecturer) }
			it { should belong_to(:unit) }
			it { should have_many(:teams).dependent(:destroy) }
			it { should have_many(:students_teams).through(:teams) }
			it { should have_many(:students).through(:students_teams) }
			it { should have_many(:iterations) }

			it { should validate_presence_of(:start_date) }
			it { should validate_presence_of(:end_date) }
			it { should validate_presence_of(:unit_id) }
			it { should validate_presence_of(:lecturer_id) }

			it { should validate_uniqueness_of(:id) }

			it 'should validate that unit_id belongs to lecturer_id' do
				project.unit = FactoryGirl.create(:unit)
				expect(project.lecturer.units).to_not include(project.unit)
				expect(project.valid?).to be_falsy
				expect(project.errors[:unit].first).to eq("does not belong in the Lecturer's list of Units")

				project.lecturer.units << project.unit
				expect(project.lecturer.units).to include(project.unit)
				expect(project.valid?).to be_truthy
			end

			it 'desroying a project should destroy its all teams' do
				project = FactoryGirl.create(:project_with_teams)
				expect(project.teams.length).to eq(2)
				expect {
					project.destroy
				}.to change { Team.all.count }.by(-2)
			end
	end
end
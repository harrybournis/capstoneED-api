require 'rails_helper'

RSpec.describe Team, type: :model do

		describe 'validations' do
			subject(:team) { FactoryGirl.build(:team) }

			it { should have_many(:students).through(:students_teams) }
			it { should belong_to(:project) }

			it { should validate_presence_of(:name) }
			it { should validate_presence_of(:enrollment_key) }
			it { should validate_presence_of(:project_id) }

			it { should validate_uniqueness_of(:id) }
			it { should validate_uniqueness_of(:enrollment_key) }
			it { should validate_uniqueness_of(:name).scoped_to(:project_id).case_insensitive }
	end
end

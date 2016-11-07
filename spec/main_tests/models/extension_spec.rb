require 'rails_helper'

RSpec.describe Extension, type: :model do

		describe 'validations' do
			it { should validate_presence_of :extra_time }
			it { should validate_presence_of :team_id }
			it { should validate_presence_of :iteration_id }

			it 'works' do
				expect(FactoryGirl.create(:extension)).to be_truthy
			end

			it 'validates uniqueness of iteration_id with scope team_id' do
				ext1 = FactoryGirl.create(:extension)
				ext2 = FactoryGirl.build(:extension, team_id: ext1.team_id, iteration_id: ext1.iteration_id)
				expect(ext2.valid?).to be_falsy
				expect(ext2.errors[:iteration_id][0]).to eq('already exists for this team_id')
			end
		end

		describe 'methods' do
			it 'returns extra_time in integer' do
				e = FactoryGirl.create(:extension)
				expect(e.extra_time.class).to eq(DateTime)
			end
		end
end

require 'rails_helper'

RSpec.describe Extension, type: :model do

		describe 'validations' do
			it { should validate_presence_of :extra_time }
			it { should validate_presence_of :project_id }
			it { should validate_presence_of :deliverable_id }

			it 'works' do
				expect(FactoryBot.create(:extension)).to be_truthy
			end

			it 'validates uniqueness of iteration_id with scope project_id' do
				ext1 = FactoryBot.create(:extension)
				ext2 = FactoryBot.build(:extension, project_id: ext1.project_id, deliverable_id: ext1.deliverable_id)
				expect(ext2.valid?).to be_falsy
				expect(ext2.errors[:deliverable_id][0]).to eq('already exists for this project_id')
			end
		end

		describe 'methods' do
		end
end

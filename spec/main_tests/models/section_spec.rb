require 'rails_helper'

RSpec.describe Section, type: :model do

	describe 'Validation' do
		it 'works' do
			expect(FactoryGirl.build(:section).valid?).to be_truthy
		end

		it { should validate_presence_of :name }
		it { should have_many :questions_sections }
		it { should have_many(:questions).through(:questions_sections) }
	end
end

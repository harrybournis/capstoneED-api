require 'rails_helper'

RSpec.describe Lecturer, type: :model do

	describe 'validations' do
		subject(:lecturer) { FactoryGirl.build(:lecturer) }

		it { should have_many(:units) }
		it { should have_many(:assignments) }
		it { should have_many(:projects).through(:assignments) }
		it { should have_many(:questions).dependent(:destroy) }
		it { should have_many :form_templates }
    it { should have_many :assignments }
    it { should have_many(:iterations).through(:assignments) }

		it { should validate_presence_of(:first_name) }
		it { should validate_presence_of(:last_name) }
		it { should validate_presence_of(:email) }
		it { should validate_presence_of(:university) }
  	it { should validate_presence_of(:position) }

  	it { should validate_uniqueness_of(:id) }
		it { should validate_uniqueness_of(:email).case_insensitive }

		it { should validate_inclusion_of(:type).in_array(['Lecturer']) }

		it 'does not allow provider to be updated' do
			lecturer = FactoryGirl.create(:lecturer)
			expect(lecturer.update(provider: 'email')).to be_truthy
			expect(lecturer.errors).to be_empty
			expect(lecturer.provider).to eq('test')
		end
	end


end

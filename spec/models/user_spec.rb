require 'rails_helper'

RSpec.describe User, type: :model do

	it { should have_one(:revoked_token) }

	describe 'validations' do
		subject(:user) { FactoryGirl.build(:user) }

		it { should validate_presence_of(:first_name) }
		it { should validate_presence_of(:last_name) }
		it { should validate_presence_of(:user_name) }
		it { should validate_presence_of(:email) }
		it { should validate_presence_of(:uid) }

		it { should validate_uniqueness_of(:user_name) }
		it { should validate_uniqueness_of(:email) }
		it { should validate_uniqueness_of(:uid) }
	end

	describe 'instance methods' do

		it 'full_name is concatenation of first_name and last_name' do
			user = FactoryGirl.create(:user, first_name: 'first', last_name: 'last')
			expect(user.full_name).to eq("first last")
		end
	end


end

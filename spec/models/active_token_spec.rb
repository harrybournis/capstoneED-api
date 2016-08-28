require 'rails_helper'

RSpec.describe ActiveToken, type: :model do

	describe 'validations' do

		it { should validate_uniqueness_of(:id) }

		it 'validate presence of exp' do
			token = ActiveToken.new(exp: '')

			expect(token.valid?).to be_falsy
			expect(token.errors[:exp]).to include("can't be blank")
		end

		it 'validate presence of user' do
			token = ActiveToken.new(exp: DateTime.now)

			expect(token.valid?).to be_falsy
			expect(token.errors[:user]).to include("can't be blank")
		end

		it 'validate presence of device' do
			token = ActiveToken.new(exp: DateTime.now)

			expect(token.valid?).to be_falsy
			expect(token.errors[:device]).to include("can't be blank")
		end

		it 'validate uniqueness of device' do
			user = FactoryGirl.create(:user)
			token = FactoryGirl.create(:active_token, device: 'same_value', user: user, exp: Time.now + 1.week)
			expect(token.valid?).to be_truthy

			new_token = ActiveToken.new(device: 'same_value', user: user, exp: 1.week.from_now)

			expect(new_token.valid?).to be_falsy
			expect(new_token.errors[:device]).to include("has already been taken")
		end

	end

end

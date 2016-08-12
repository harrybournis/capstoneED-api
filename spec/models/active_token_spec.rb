require 'rails_helper'

RSpec.describe ActiveToken, type: :model do

	describe 'validations' do

		it 'validate presence of jti' do
			token = ActiveToken.new(jti: '', exp: DateTime.now)

			expect(token.valid?).to be_falsy
			expect(token.errors[:jti]).to include("can't be blank")
		end

		it 'validate presence of exp' do
			token = ActiveToken.new(jti: 'unique_id', exp: '')

			expect(token.valid?).to be_falsy
			expect(token.errors[:exp]).to include("can't be blank")
		end

		it 'validate presence of user' do
			token = ActiveToken.new(jti: 'unique_id', exp: DateTime.now)

			expect(token.valid?).to be_falsy
			expect(token.errors[:user]).to include("can't be blank")
		end

		it 'validate presence of device' do
			token = ActiveToken.new(jti: 'unique_id', exp: DateTime.now)

			expect(token.valid?).to be_falsy
			expect(token.errors[:device]).to include("can't be blank")
		end

		it 'validate uniqueness of device' do
			user = FactoryGirl.create(:user)
			token = FactoryGirl.create(:active_token, device: 'same_value', user: user, jti: user.uid, exp: Time.now + 1.week)
			expect(token.valid?).to be_truthy

			new_token = ActiveToken.new(device: 'same_value', user: user, jti: user.uid, exp: 1.week.from_now)

			expect(new_token.valid?).to be_falsy
			expect(new_token.errors[:device]).to include("has already been taken")
		end

		it 'jti should be equal to the users uid' do
			user = FactoryGirl.create(:user, uid: "unique_id")
			token = ActiveToken.new(jti: "different_value", exp: DateTime.now, user: user)


			expect(token.valid?).to be_falsy
			expect(token.errors[:jti]).to include("jti must match the associated user's uid")
		end
	end

end

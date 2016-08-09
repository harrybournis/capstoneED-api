require 'rails_helper'

RSpec.describe RevokedToken, type: :model do

	describe 'validations' do

		it 'validate presence of jti' do
			user = FactoryGirl.create(:user, uid: 'unique_id')
			token = RevokedToken.new(jti: '', exp: DateTime.now, user: user)

			expect(token.valid?).to be_falsy
			expect(token.errors[:jti]).to include("can't be blank")
		end

		it 'validate presence of exp' do
			user = FactoryGirl.create(:user, uid: 'unique_id')
			token = RevokedToken.new(jti: 'unique_id', exp: '', user: user)

			expect(token.valid?).to be_falsy
			expect(token.errors[:exp]).to include("can't be blank")
		end

		it 'validate presence of user' do
			token = RevokedToken.new(jti: 'unique_id', exp: DateTime.now)

			expect(token.valid?).to be_falsy
			expect(token.errors[:user]).to include("can't be blank")
		end

		it 'validate uniqueness of jti' do
			user = FactoryGirl.create(:user, uid: 'same_id')
			user.revoke_all_tokens

			token = RevokedToken.new(jti: 'same_id', exp: DateTime.now, user: user)

			expect(token.valid?).to be_falsy
			expect(token.errors[:jti]).to include("has already been taken")
		end

		it 'validate uniqueness of user' do
			user = FactoryGirl.create(:user, uid: 'same_id')
			user.revoke_all_tokens

			token = RevokedToken.new(jti: 'same_id', exp: DateTime.now, user: user)

			expect(token.valid?).to be_falsy
			expect(token.errors[:user]).to include("has already been taken")
		end

		it 'jti should be equal to the users uid' do
			user = FactoryGirl.create(:user, uid: "unique_id")
			token = RevokedToken.new(jti: "different_value", exp: DateTime.now, user: user)


			expect(token.valid?).to be_falsy
			expect(token.errors[:jti]).to include("jti must match the associated user's uid")
		end
	end

end

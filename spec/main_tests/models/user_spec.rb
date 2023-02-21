require 'rails_helper'

RSpec.describe User, type: :model do

	it { should have_many(:active_tokens) }

	describe 'devise defaults' do
		it 'should strip whitespace from password' do
			user = build :user_with_password, password: ' 12345678 ', password_confirmation: ' 12345678 '
			expect(user.save).to be_truthy
			expect(user.valid_password?('12345678')).to be_truthy

			user = build :user_with_password, password: '12345678', password_confirmation: '12345678'
			expect(user.save).to be_truthy
			expect(user.valid_password?('12345678')).to be_truthy
		end
	end

	describe 'instance methods' do

		it 'full_name is concatenation of first_name and last_name' do
			user = FactoryBot.create(:student, first_name: 'first', last_name: 'last')
			expect(user.full_name).to eq("first last")
		end

	end

	describe 'revoke tokens' do

		context 'when no revoked token exist in the database' do
			it 'no new tokes should be created' do
				user = FactoryBot.create(:user)
				expect(user.active_tokens.count).to eq(0)

				user.revoke_all_tokens
				expect(user.active_tokens.count).to eq(0)
				expect(ActiveToken.last.jti).to_not eq(user.uid) if ActiveToken.last
			end
		end

		context 'when revoked token exist' do
			it 'should update all of them to the new expiry date' do
				user = FactoryBot.create(:user)
				time_old1 = Time.now - 1.hour
				time_old2 = Time.now - 10.minutes
				token1 = FactoryBot.create(:active_token, exp: time_old1, user: user, device: SecureRandom.base64(32))
				token2 = FactoryBot.create(:active_token, exp: time_old2, user: user, device: SecureRandom.base64(32))

				expect(token1).to be_truthy
				expect(token2).to be_truthy
				expect(user.active_tokens.count).to eq(2)

				user.revoke_all_tokens

				user.active_tokens.each do |t|
					expect(t.exp).to be > time_old1
					expect(t.exp).to be > time_old2
				end
				expect(user.active_tokens[0].exp).to eq(user.active_tokens[1].exp)
			end
		end
	end
end

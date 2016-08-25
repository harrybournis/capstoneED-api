require 'rails_helper'

RSpec.describe User, type: :model do

	it { should have_many(:active_tokens) }

	describe 'validations' do
		subject(:user) { FactoryGirl.build(:user) }

		it { should validate_presence_of(:first_name) }
		it { should validate_presence_of(:last_name) }
		it { should validate_presence_of(:email) }

		it { should validate_uniqueness_of(:email).case_insensitive }

		it 'should validate type is not nil'

		it 'does not allow provider to be updated' do
			user = FactoryGirl.create(:user)
			expect(user.update(provider: 'email')).to be_truthy
			expect(user.errors).to be_empty
			expect(user.provider).to eq('test')
		end
	end

	describe 'instance methods' do

		it 'full_name is concatenation of first_name and last_name' do
			user = FactoryGirl.create(:user, first_name: 'first', last_name: 'last')
			expect(user.full_name).to eq("first last")
		end

		it 'after initialize should generate and provide a uid token' do
			params = FactoryGirl.attributes_for :user
			params.delete(:uid)
			expect(params[:uid]).to be_falsy

			user = User.new(params).process_new_record
			user.valid?
			expect(user.errors['uid']).to be_empty
		end

	end

	describe 'revoke tokens' do

		context 'when no revoked token exist in the database' do
			it 'no new tokes should be created' do
				user = FactoryGirl.create(:user)
				expect(user.active_tokens.count).to eq(0)

				user.revoke_all_tokens
				expect(user.active_tokens.count).to eq(0)
				expect(ActiveToken.last.jti).to_not eq(user.uid) if ActiveToken.last
			end
		end

		context 'when revoked token exist' do
			it 'should update all of them to the new expiry date' do
				user = FactoryGirl.create(:user)
				time_old1 = Time.now - 1.hour
				time_old2 = Time.now - 10.minutes
				token1 = FactoryGirl.create(:active_token, exp: time_old1, user: user, device: SecureRandom.base64(32))
				token2 = FactoryGirl.create(:active_token, exp: time_old2, user: user, device: SecureRandom.base64(32))

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

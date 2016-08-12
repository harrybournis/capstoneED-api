require 'rails_helper'

RSpec.describe User, type: :model do

	it { should have_many(:active_tokens) }

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

	describe 'revoke tokens' do

		context 'when no revoked token exist in the database' do
			it 'should create a new entry with the current Time as expiration' do
				user = FactoryGirl.create(:user)

				user.revoke_all_tokens
				expect(user.active_tokens.count).to eq(1)
				expect(ActiveToken.last.jti).to eq(user.uid)
			end

		end

		# it "should create a new entry when it doesn't have one" do
		# 	user = FactoryGirl.create(:user)

		# 	user.revoke_all_tokens
		# 	expect(user.active_token).to be_truthy
		# 	expect(ActiveToken.last.jti).to eq(user.uid)
		#

		# it 'should update the entry when it already has a active_token' do
		# 	user = FactoryGirl.create(:user, uid: "uid")
		# 	active_token = FactoryGirl.create(:active_token, user: user, jti: "uid")

		# 	user.revoke_all_tokens
		# 	expect(user.active_token.id).to eq(active_token.id)
		#
	end
end

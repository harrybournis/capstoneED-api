require 'rails_helper'

RSpec.describe UserParamsWrapper do
	it '["email"] should equal params["user"]["public_email"]' do
		params = { 'user' => { 'public_email' => 'email@email.com', 'password' => '12345678' } }
		presenter  = UserParamsWrapper.new(params)

		presenter.define_singleton_method(:email_test_only) { params['user']['public_email'] }

		expect(presenter.email_test_only).to eq(params['user']['public_email'])
	end
end

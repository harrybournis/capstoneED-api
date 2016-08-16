require 'rails_helper'

RSpec.describe BaseParamsWrapper do

	it '["email"] should delegate to params["email"]' do
		params 	= { 'email' => 'email@email.com', 'password' => '12345678' }
		presenter  = BaseParamsWrapper.new(params)

		expect(presenter['email']).to eq(params['email'])
	end

	it '["email"] should delegate to nested params params["user"]["email"]' do
		params = { 'user' => { 'email' => 'email@email.com', 'password' => '12345678' } }
		presenter  = BaseParamsWrapper.new(params['user'])

		expect(presenter['email']).to eq(params['user']['email'])
	end
end

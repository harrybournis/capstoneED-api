require 'rails_helper'

RSpec.describe JWTAuthenticator2, type: :request do

	before do
		get v1_users_path, constraints: {subdomain: 'api'}
	end

	it 'testddd' do
		expect(JWTAuthenticator2.validate_request(request).maimou).to be_falsy
	end

end

require 'rails_helper'

RSpec.describe 'Routing', type: :routing do

	let(:url) { 'http://api.example.com' }

	it 'GET /projects?unit_id=3 routes to index_with_unit' do
		expect(get: "#{url}/v1/projects?unit_id=3").to route_to(controller: 'v1/projects', action: 'index_with_unit', subdomain: 'api', unit_id: "3")
	end
end

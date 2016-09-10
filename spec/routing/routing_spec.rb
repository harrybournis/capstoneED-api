require 'rails_helper'

RSpec.describe 'Routing', type: :routing do

	let(:url) { 'http://api.example.com' }

	it 'GET /projects?unit_id=3 routes to index_with_unit' do
		expect(get: "#{url}/v1/projects?unit_id=3").to route_to(
			controller: 'v1/projects', action: 'index_with_unit', subdomain: 'api', unit_id: "3")
	end

	it 'GET /projects routes to the normal projects index' do
		expect(get: "#{url}/v1/projects").to route_to(
			controller: 'v1/projects', action: 'index', subdomain: 'api')
	end

	it 'GET /teams?project_id=3 routes to index_with_project' do
		expect(get: "#{url}/v1/teams?project_id=3").to route_to(
			controller: 'v1/teams', action: 'index_with_project', subdomain: 'api', project_id: '3')
	end

	it 'GET /teams? routes to normal teams index' do
		expect(get: "#{url}/v1/teams").to route_to(
			controller: 'v1/teams', action: 'index', subdomain: 'api')
	end
end

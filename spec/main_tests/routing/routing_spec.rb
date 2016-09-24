require 'rails_helper'

RSpec.describe 'Routing', type: :routing do

	let(:url) { 'http://example.com' }

	it 'GET /projects?unit_id=3 routes to index_with_unit' do
		expect(get: "#{url}/v1/projects?unit_id=3").to route_to(
			controller: 'v1/projects', action: 'index_with_unit', unit_id: "3")
	end

	it 'GET /projects routes to the normal projects index' do
		expect(get: "#{url}/v1/projects").to route_to(
			controller: 'v1/projects', action: 'index')
	end

	it 'GET /teams?project_id=3 routes to index_with_project' do
		expect(get: "#{url}/v1/teams?project_id=3").to route_to(
			controller: 'v1/teams', action: 'index_with_project', project_id: '3')
	end

	it 'GET /teams? routes to normal teams index' do
		expect(get: "#{url}/v1/teams").to route_to(
			controller: 'v1/teams', action: 'index')
	end

	it 'GET /iterations?project_id routes to iterations index' do
		expect(get: "#{url}/v1/iterations?project_id=3").to route_to(
			controller: 'v1/iterations', action: 'index', project_id: '3')
	end

	it 'DELETE /teams/:id/remove_student routes to teams remove_student' do
		expect(delete: "#{url}/v1/teams/4/remove_student").to route_to(
			controller: 'v1/teams', action: 'remove_student', id: '4')
	end

	it 'GET /peer_assessments?pa_form_id routes to index_with_pa_form' do
		expect(get: "#{url}/v1/peer_assessments?pa_form_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index_with_pa_form', pa_form_id: '2')
	end

	it 'GET /peer_assessments?submitted_for_id routes to index_with_submitted_for' do
		expect(get: "#{url}/v1/peer_assessments?submitted_for_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index_with_submitted_for', submitted_for_id: '2')
	end

	it 'GET /peer_assessments?submitted_for_id routes to index_with_submitted_for' do
		expect(get: "#{url}/v1/peer_assessments?submitted_by_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index_with_submitted_by', submitted_by_id: '2')
	end

	it 'GET /peer_assessments routes to index' do
		expect(get: "#{url}/v1/peer_assessments").to route_to(
			controller: 'v1/peer_assessments', action: 'index')
	end

end

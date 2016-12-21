require 'rails_helper'

RSpec.describe 'Routing', type: :routing do

	let(:url) { 'http://example.com' }

	it 'GET /assignments?unit_id=3 routes to index_with_unit' do
		expect(get: "#{url}/v1/assignments?unit_id=3").to route_to(
			controller: 'v1/assignments', action: 'index_with_unit', unit_id: "3")
	end

	it 'GET /assignments routes to the normal assignments index' do
		expect(get: "#{url}/v1/assignments").to route_to(
			controller: 'v1/assignments', action: 'index')
	end

	it 'GET /projects?assignment_id=3 routes to index_with_assignment' do
		expect(get: "#{url}/v1/projects?assignment_id=3").to route_to(
			controller: 'v1/projects', action: 'index_with_assignment', assignment_id: '3')
	end

	it 'GET /projects? routes to normal projects index' do
		expect(get: "#{url}/v1/projects").to route_to(
			controller: 'v1/projects', action: 'index')
	end

	it 'GET /iterations?assignment_id routes to iterations index' do
		expect(get: "#{url}/v1/iterations?assignment_id=3").to route_to(
			controller: 'v1/iterations', action: 'index', assignment_id: '3')
	end

	it 'DELETE /projects/:id/remove_student routes to projects remove_student' do
		expect(delete: "#{url}/v1/project/4/remove_student").to route_to(
			controller: 'v1/projects', action: 'remove_student', id: '4')
	end

	it 'GET /peer_assessments?pa_form_id routes to index_with_pa_form' do
		expect(get: "#{url}/v1/peer_assessments?pa_form_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index_with_pa_form', pa_form_id: '2')
	end

	it 'GET /peer_assessments?submitted_for_id routes to index_with_submitted_for' do
		expect(get: "#{url}/v1/peer_assessments?pa_form_id=1&submitted_for_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index_with_submitted_for', submitted_for_id: '2', pa_form_id: '1')
	end

	it 'GET /peer_assessments?submitted_for_id routes to index_with_submitted_for' do
		expect(get: "#{url}/v1/peer_assessments?pa_form_id=1&submitted_by_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index_with_submitted_by', submitted_by_id: '2', pa_form_id: '1')
	end

	it 'GET /peer_assessments routes to index' do
		expect(get: "#{url}/v1/peer_assessments").to route_to(
			controller: 'v1/peer_assessments', action: 'index')
	end

	it 'GET /project/:id/evaluations to project_evaluations index with project' do
		expect(get: "#{url}/v1/project/3/evaluations").to route_to(
			controller: 'v1/project_evaluations', action: 'index_with_project', project_id: '3')
	end

	it 'GET /iteration/:id/evaluations to project_evaluations index with iteration' do
		expect(get: "#{url}/v1/iteration/3/evaluations").to route_to(
			controller: 'v1/project_evaluations', action: 'index_with_iteration', iteration_id: '3')
	end
end

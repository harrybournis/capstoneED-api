require 'rails_helper'

RSpec.describe 'Routing', type: :routing do

	let(:url) { 'http://example.com' }

	# Assignment

	it 'GET /assignments?unit_id=3 routes to index_with_unit' do
		expect(get: "#{url}/v1/assignments?unit_id=3").to route_to(
			controller: 'v1/assignments', action: 'index_with_unit', unit_id: "3")
	end

	it 'GET /assignments routes to the normal assignments index' do
		expect(get: "#{url}/v1/assignments").to route_to(
			controller: 'v1/assignments', action: 'index')
	end

	# units

	it 'GET /units/archived routes to units#index_archived' do
		expect(get: "#{url}/v1/units/archived").to route_to(
			controller: 'v1/units', action: 'index_archived')
	end

	it 'PATCH /units/:id/archive routes to units#archive' do
		expect(patch: "#{url}/v1/units/4/archive").to route_to(
			controller: 'v1/units', action: 'archive', id: "4")
	end

	# iterations

	it 'GET /iterations?assignment_id routes to iterations index' do
		expect(get: "#{url}/v1/iterations?assignment_id=3").to route_to(
			controller: 'v1/iterations', action: 'index', assignment_id: '3')
	end

	it 'GET /iteration/:id/evaluations to project_evaluations index with iteration' do
		expect(get: "#{url}/v1/iterations/3/evaluations").to route_to(
			controller: 'v1/project_evaluations', action: 'index_with_iteration', iteration_id: '3')
	end

	# pa form
	it 'GET /v1/pa_forms to PAFormController#index' do
		expect(get: "#{url}/v1/pa_forms").to route_to(
					 controller: 'v1/pa_forms', action: 'index')
	end

	# peer assessments

	it 'GET /peer_assessments?pa_form_id routes to index' do
		expect(get: "#{url}/v1/peer_assessments?pa_form_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index', pa_form_id: '2')
	end

	it 'GET /peer_assessments?submitted_for_id routes to index' do
		expect(get: "#{url}/v1/peer_assessments?pa_form_id=1&submitted_for_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index', submitted_for_id: '2', pa_form_id: '1')
	end

	it 'GET /peer_assessments?submitted_for_id routes to index' do
		expect(get: "#{url}/v1/peer_assessments?pa_form_id=1&submitted_by_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index', submitted_by_id: '2', pa_form_id: '1')
	end

	it 'GET /peer_assessments?pa_form_id routes to index' do
		expect(get: "#{url}/v1/peer_assessments?pa_form_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index', pa_form_id: '2')
	end

	it 'GET /peer_assessments?project_id routes to index' do
		expect(get: "#{url}/v1/peer_assessments?project_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index', project_id: '2')
	end

	it 'GET /peer_assessments?iteration_id routes to index' do
		expect(get: "#{url}/v1/peer_assessments?iteration_id=2").to route_to(
			controller: 'v1/peer_assessments', action: 'index', iteration_id: '2')
	end

	it 'GET /peer_assessments routes to index_error' do
		expect(get: "#{url}/v1/peer_assessments").to route_to(
			controller: 'v1/peer_assessments', action: 'index')
	end
end

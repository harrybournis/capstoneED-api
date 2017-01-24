require 'rails_helper'

RSpec.describe 'Routing', type: :routing do

	let(:url) { 'http://example.com' }

	# Password
	it 'POST /request_reset_password routes to passwords#create' do
		expect(post: "#{url}/v1/request_reset_password").to route_to(
			controller: 'v1/passwords', action: 'create')
	end

	it 'PATCH /reset_password routes to passwords#update' do
		expect(patch: "#{url}/v1/reset_password").to route_to(
			controller: 'v1/passwords', action: 'update')
	end

	it 'POST /resend_confirmation_email to confirmations#create' do
		expect(post: "#{url}/v1/resend_confirmation_email").to route_to(
			controller: 'v1/confirmations', action: 'create')
	end

	it 'GET /confirm_account to confirmations#show' do
		expect(get: "#{url}/v1/confirm_account").to route_to(
			controller: 'v1/confirmations', action: 'show')
	end

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

	it 'GET /projects?unit_id=3 routes to index_with_assignment' do
		expect(get: "#{url}/v1/projects?unit_id=3").to route_to(
			controller: 'v1/projects', action: 'index_with_unit', unit_id: '3')
	end

	it 'GET /projects? routes to normal projects index' do
		expect(get: "#{url}/v1/projects").to route_to(
			controller: 'v1/projects', action: 'index')
	end

	it 'GET /iterations?assignment_id routes to iterations index' do
		expect(get: "#{url}/v1/iterations?assignment_id=3").to route_to(
			controller: 'v1/iterations', action: 'index', assignment_id: '3')
	end

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

	it 'GET /project/:id/evaluations to project_evaluations index with project' do
		expect(get: "#{url}/v1/projects/3/evaluations").to route_to(
			controller: 'v1/project_evaluations', action: 'index_with_project', project_id: '3')
	end

	it 'GET /iteration/:id/evaluations to project_evaluations index with iteration' do
		expect(get: "#{url}/v1/iterations/3/evaluations").to route_to(
			controller: 'v1/project_evaluations', action: 'index_with_iteration', iteration_id: '3')
	end

	it 'GET /projects/:id/update_nickname to StudentsProjectsController#update_nickname' do
		expect(patch: "#{url}/v1/projects/3/update_nickname").to route_to(
			controller: 'v1/students_projects', action: 'update_nickname', id: '3')
	end

	it 'POST /projects/enrol to StudentsProjectsController#enrol' do
		expect(post: "#{url}/v1/projects/enrol").to route_to(
			controller: 'v1/students_projects', action: 'enrol')
	end

	it 'DELETE /projects/:id/remove_student routes to students_projects#remove_student' do
		expect(delete: "#{url}/v1/projects/4/remove_student").to route_to(
			controller: 'v1/students_projects', action: 'remove_student', id: '4')
	end

	it 'POST /projects/:id/logs routes to students_projects#update_logs' do
		expect(post: "#{url}/v1/projects/3/logs").to route_to(
			controller: 'v1/students_projects', action: 'update_logs', id: '3')
	end

	it 'GET /projects/:id/logs routes to students_projects#index_logs_student' do
		expect(get: "#{url}/v1/projects/3/logs").to route_to(
			controller: 'v1/students_projects', action: 'index_logs_student', id: '3')
	end

	it 'GET /projects/:id/logs?student_id=4 routes to students_projects#index_logs_lecturer' do
		expect(get: "#{url}/v1/projects/3/logs?student_id=4").to route_to(
			controller: 'v1/students_projects', action: 'index_logs_lecturer', id: '3', student_id: '4')
	end

	it 'GET /units/archived routes to units#index_archived' do
		expect(get: "#{url}/v1/units/archived").to route_to(
			controller: 'v1/units', action: 'index_archived')
	end

	it 'PATCH /units/:id/archive routes to units#archive' do
		expect(patch: "#{url}/v1/units/4/archive").to route_to(
			controller: 'v1/units', action: 'archive', id: "4")
	end
end

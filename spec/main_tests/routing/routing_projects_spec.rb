require 'rails_helper'

RSpec.describe 'Routing', type: :routing do

  let(:url) { 'http://example.com' }

  # projects

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

  it 'GET /project/:id/evaluations to project_evaluations index with project' do
    expect(get: "#{url}/v1/projects/3/evaluations").to route_to(
      controller: 'v1/project_evaluations', action: 'index_with_project', project_id: '3')
  end
end

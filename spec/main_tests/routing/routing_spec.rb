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

  it 'GET /scored-iterations routes to iterations scored iterations index' do
    expect(get: "#{url}/v1/scored-iterations").to route_to(
      controller: 'v1/iterations/scored_iterations', action: 'index')
  end

  it 'GET /scored-iterations routes to scored-iterations#show' do
    expect(get: "#{url}/v1/scored-iterations/#{1}").to route_to(
      controller: 'v1/iterations/scored_iterations', action: 'show', id: "1")
  end

  # pa form

  it 'GET /v1/pa_forms to PAFormController#index' do
    expect(get: "#{url}/v1/pa_forms").to route_to(
      controller: 'v1/pa_forms', action: 'index')
  end

  # create pa_forms for each iteration of assignment
  it 'POST /v1/assignments/:assignment_id/pa_forms to PAFormController#create_for_each_iteration' do
    expect(post: "#{url}/v1/assignments/2/pa_forms").to route_to(
      controller: 'v1/pa_forms', action: 'create_for_each_iteration', assignment_id: '2')
  end

  # question types
  it 'GET /v1/question_types to QuestionTypesController#index' do
    expect(get: "#{url}/v1/question_types").to route_to(
      controller: 'v1/question_types', action: 'index')
  end

  # game settings

  it 'GET /v1/assignments/2/game_settings to route to GameSettings#index' do
    expect(get: "#{url}/v1/assignments/2/game_settings").to route_to(
      controller: 'v1/game_settings', action: 'index', assignment_id: "2")
  end

  it 'POST /v1/assignments/2/game_settings to route to GameSettings#create' do
    expect(post: "#{url}/v1/assignments/2/game_settings").to route_to(
      controller: 'v1/game_settings', action: 'create', assignment_id: "2")
  end

  it 'PATCH /v1/assignments/2/game_settings to route to GameSettings#create' do
    expect(patch: "#{url}/v1/assignments/2/game_settings").to route_to(
      controller: 'v1/game_settings', action: 'update', assignment_id: "2")
  end

  # Points

  it 'GET /v1/projects/:id/points to route to Points#index_for_project' do
    expect(get: "#{url}/v1/projects/1/points").to route_to(
      controller: 'v1/points', action: 'index_for_project', project_id: '1')
  end

  it 'GET /v1/assignments/:id/points to route to Points#index_for_assignment' do
    expect(get: "#{url}/v1/assignments/1/points").to route_to(
      controller: 'v1/points', action: 'index_for_assignment', assignment_id: '1')
  end

  # Project Evaluations

  it 'POST /v1/projects/:id/evaluations to route to project_evaluations#create' do
    expect(post: "#{url}/v1/projects/1/evaluations").to route_to(
      controller: 'v1/project_evaluations', action: 'create', project_id: '1')
  end

  # it 'PATCH /v1/projects/:id/evaluations to route to project_evaluations#update' do
  # expect(patch: "#{url}/v1/projects/1/evaluations").to route_to(
  # controller: 'v1/project_evaluations', action: 'update', project_id: '1')
  # end

  it 'GET /iteration/:id/evaluations to project_evaluations index with iteration' do
    expect(get: "#{url}/v1/iterations/3/evaluations").to route_to(
      controller: 'v1/project_evaluations', action: 'index_with_iteration', iteration_id: '3')
  end

  it 'GET /v1/project-evaluations to route to project_evaluations#index' do
    expect(get: "#{url}/v1/project-evaluations").to route_to(
      controller: 'v1/project_evaluations', action: 'index')
  end

  # Reasons

  it 'GET /v1/reasons to route to reasons#index' do
    expect(get: "#{url}/v1/reasons").to route_to(
      controller: 'v1/reasons', action: 'index')
  end

end

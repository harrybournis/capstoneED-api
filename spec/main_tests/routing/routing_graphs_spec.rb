require 'rails_helper'

RSpec.describe 'Stats Routing', type: :routing do

  let(:url) { 'http://example.com' }

  it 'GET /stats?graph=hours_worked routes to hours_worked' do
    expect(get: "#{url}/v1/stats?graph=hours_worked&project_id=2").to route_to(
      controller: 'v1/logs/stats', action: 'hours_worked_project', graph: "hours_worked", project_id: "2")
  end

  it 'GET /stats?graph=percent_completion routes to percent_completion' do
    expect(get: "#{url}/v1/stats?graph=percent_completion").to route_to(
      controller: 'v1/project_evaluations/stats', action: 'percent_completion', graph: 'percent_completion')
  end

  it 'GET /stats?graph=hours_worked&assignment_id routes to hours_worked_assignment' do
    expect(get: "#{url}/v1/stats?graph=hours_worked&assignment_id=3").to route_to(
      controller: 'v1/logs/stats', action: 'hours_worked_assignment', graph: "hours_worked", assignment_id: "3")
  end

end
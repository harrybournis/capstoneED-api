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

  it 'GET /stats?graph=hours_worked without assignment_id or project_id routes to project to show error' do
    expect(get: "#{url}/v1/stats?graph=hours_worked").to route_to(
      controller: 'v1/logs/stats', action: 'hours_worked_project', graph: "hours_worked")
  end

  it 'GET /stats?graph=logs_heatmap&project_id routes to logs_heatmap' do
    expect(get: "#{url}/v1/stats?graph=logs_heatmap&project_id=5").to route_to(controller: 'v1/logs/stats', action: 'logs_heatmap', graph: 'logs_heatmap', project_id: "5")
  end

end

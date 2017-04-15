require 'rails_helper'

RSpec.describe 'Routing', type: :routing do

  let(:url) { 'http://example.com' }

  # Logs

  it 'GET projects/:id/logs routes to index_logs_student' do
    expect(get: "#{url}/v1/projects/2/logs").to route_to(
      controller: 'v1/logs', action: 'index_student', id: "2")
  end

  it 'GET projects/:id/logs?studentid=5 routes to index_logs_lecturer' do
    expect(get: "#{url}/v1/projects/2/logs?student_id=7").to route_to(
      controller: 'v1/logs', action: 'index_lecturer', id: "2", student_id: "7")
  end

  it 'POST projects/:id/logs routes to update' do
    expect(post: "#{url}/v1/projects/2/logs").to route_to(
      controller: 'v1/logs', action: 'update', id: "2")
  end
end

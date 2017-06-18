require 'rails_helper'

RSpec.describe 'Routing', type: :routing do

  let(:url) { 'http://example.com' }

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

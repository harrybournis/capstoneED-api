require 'rails_helper'

RSpec.describe 'Stats Routing', type: :routing do

  let(:url) { 'http://example.com' }

  it 'GET GET /stats?graph=hours_worked routes to hours_worked' do
    expect(get: "#{url}/v1/stats?graph=hours_worked").to route_to(
      controller: 'v1/logs/stats', action: 'hours_worked', graph: "hours_worked")
  end


end

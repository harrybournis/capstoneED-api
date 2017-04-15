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
    expect(get: "#{url}/v1/confirm_account?confirmation_token=HHwiAAjkA_ozbwNYzXm5").to route_to(
      controller: 'v1/confirmations', action: 'show', confirmation_token: "HHwiAAjkA_ozbwNYzXm5")
  end
end

require 'rails_helper'

RSpec.describe "V1::PaFormsController", type: :request do

  before(:each) { host! 'api.example.com' }

  it 'returns the active forms' do
    csrf = sign_in FactoryBot.create(:student_confirmed)

    get "/v1/pa_forms", headers: { 'X-XSRF-TOKEN' => csrf }

    expect(status).to eq 204
  end
end

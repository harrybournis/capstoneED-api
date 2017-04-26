require 'rails_helper'

RSpec.describe V1::FormTemplatesController, type: :controller do
  before :each do
    @controller = V1::FormTemplatesController.new
    @lecturer = create :lecturer_confirmed
    mock_request = MockRequest.new(valid = true, @lecturer)
    request.cookies['access-token'] = mock_request.cookies['access-token']
    request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
  end

  describe 'index responds with ' do
    it '200 and all FormTemplates for the current user', { docs?: true } do
      2.times { create(:form_template, lecturer: @lecturer) }

      get :index

      expect(status).to eq 200
      expect(body['form_templates']).to be_truthy
      expect(body['form_templates'].length).to eq 2
    end

    it '403 if current_user is a student' do
      student = create :student_confirmed
      mock_request = MockRequest.new(valid = true, student)
      request.cookies['access-token'] = mock_request.cookies['access-token']
      request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

      get :index

      expect(status).to eq 403
      expect(errors_base[0]).to include 'Lecturer'
    end
  end

  describe 'update responds with' do
    it '200 if no errors', { docs?: true } do
      form_template = create :form_template, lecturer: @lecturer

      patch :update, params: { id: form_template.id, name: 'new name', questions: valid_questions }

      expect(status).to eq 200
      expect(body['form_template']['name']).to eq 'new name'
    end

    it '422 if invalid questions' do
      form_template = create :form_template, lecturer: @lecturer

      patch :update, params: { id: form_template.id, name: 'new name', questions: { questions: ['Who is it?', 'Human?'] }  }

      expect(status).to eq 422
      expect(errors['questions']).to be_truthy
    end

    it '403 if current user is not associated with the current_user' do
      form_template = create :form_template

      patch :update, params: { id: form_template.id, name: 'new name', questions: valid_questions }

      expect(status).to eq 403
      expect(errors_base[0]).to include 'associated'
    end
  end

  describe 'create responds with' do
    it '200 if no errors', { docs?: true } do
      post :create, params: { name: 'new name', questions: valid_questions }

      expect(status).to eq 201
      expect(body['form_template']['name']).to eq 'new name'
      expect(body['form_template']['lecturer_id']).to eq @lecturer.id
    end

    it '422 if invalid questions' do
      post :create, params: { name: 'new name', questions: { questions: ['Who is it?', 'Human?'] }  }

      expect(status).to eq 422
      expect(errors['questions']).to be_truthy
    end
  end

  describe 'destroy responds with' do
    it '200 if no errors', { docs?: true } do
      form_template = create :form_template, lecturer: @lecturer

      expect {
        delete :destroy, params: { id: form_template.id }
      }.to change { FormTemplate.count }.by(-1)

      expect(status).to eq 204
    end

    it '403 if current user is not associated with the current_user' do
      form_template = create :form_template

      expect {
        delete :destroy, params: { id: form_template.id }
      }.to_not change { FormTemplate.count }

      expect(status).to eq 403
    end
  end
end

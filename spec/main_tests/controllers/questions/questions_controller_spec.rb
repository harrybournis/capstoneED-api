require 'rails_helper'

RSpec.describe V1::QuestionsController, type: :controller do

	context 'Valid' do

		before(:each) do
			@controller = V1::QuestionsController.new
			@user = FactoryGirl.create(:lecturer)
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			5.times { @user.questions << FactoryGirl.build(:question) }
			expect(@user.questions.count).to eq(5)
			4.times { FactoryGirl.create(:question) }
		end

		it 'GET index returns the questions scoped to the current user', { docs?: true } do
			get :index
			expect(status).to eq(200)
			expect(body['questions'].length).to eq(5)
		end

		it 'GET show returns the question if it belongs to user' do
			get :show, params: { id: @user.questions[0] }
			expect(status).to eq(200)
			expect(body['question']['id']).to eq(@user.questions[0].id)
		end

		it 'POST create creates a new question for current_user' do
			qtype = create :question_type
			post :create, params: { category: 'Question', text: 'Yo', question_type_id: qtype.id }
			expect(status).to eq(201)
			expect(@user.questions.ids).to include(body['question']['id'])
		end

		it 'PATCH update updates the question if it bleongs to user' do
			patch :update, params: { id: @user.questions[0].id, text: 'newtext' }
			expect(body['question']['text']).to eq('newtext')
			expect(Question.find(body['question']['id']).text).to eq('newtext')
		end

		it 'DELETE destroy deletes the questio if it belongs to user' do
			delete :destroy, params: { id: @user.questions[0].id }
			expect(status).to eq(204)
		end
	end


	context 'Invalid' do

		before(:each) do
			@controller = V1::QuestionsController.new
			@user = FactoryGirl.create(:lecturer)
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			5.times { @user.questions << FactoryGirl.build(:question) }
			expect(@user.questions.count).to eq(5)
			4.times { FactoryGirl.create(:question) }
		end

		it 'only Lecturers are allowed' do
			@user = FactoryGirl.create(:student)
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			get :index
			expect(status).to eq(403)
			expect(body['errors']['base'][0]).to include("must be Lecturer")

			get :show, params: { id: Question.last.id }
			expect(status).to eq(403)
			expect(body['errors']['base'][0]).to include("must be Lecturer")

			post :create, params: { text: 'dfds', category: 'teds' }
			expect(status).to eq(403)
			expect(body['errors']['base'][0]).to include("must be Lecturer")

			patch :update, params: { id: Question.last.id }
			expect(status).to eq(403)
			expect(body['errors']['base'][0]).to include("must be Lecturer")

			delete :destroy, params: { id: Question.last.id }
			expect(status).to eq(403)
			expect(body['errors']['base'][0]).to include("must be Lecturer")
		end

		it 'GET show responds with 403 if question belongs to another lecturer' do
			get :show, params: { id: Question.where("lecturer_id != #{@user.id}")[0].id }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated with the current user')
		end

		it 'POST create responds with 422 if missing params' do
			post :create, params: { category: 'Question' }
			expect(status).to eq(422)
			expect(errors['text'][0]).to eq("can't be blank")
		end

		it 'PATCH update responds with 422 if it does not belong to user' do
			patch :update, params: { id: Question.where("lecturer_id != #{@user.id}")[0].id, text: 'newtext' }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated with the current user')
		end

		it 'DELETE destroy deletes the questio if it belongs to user' do
			delete :destroy, params: { id: Question.where("lecturer_id != #{@user.id}")[0].id }
			expect(status).to eq(403)
			expect(errors['base'][0]).to include('not associated with the current user')
		end
	end
end

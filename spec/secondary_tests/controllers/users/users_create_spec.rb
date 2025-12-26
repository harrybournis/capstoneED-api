require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do

	# before(:each) do
	# 	@controller = V1::UsersController.new
	# 	@lecturer = FactoryBot.build(:lecturer_with_password).process_new_record
	# 	@lecturer.save
	# 	@lecturer.confirm
	# end

	it 'creates new lecturer at POST /v1/users' do
		post :create, params: { type: 'Lecturer', email: 'emailuniquegreat@yahoo.com', password: '12345678', password_confirmation: '12345678', first_name: 'first', last_name: 'last', university: 'somthing', position: 'someone' }
		expect(body['user']['email']).to eq('emailuniquegreat@yahoo.com')
		expect(body['user']['type']).to eq('Lecturer')
	end

	it 'creates new student at POST /v1/users' do
		post :create, params: { type: 'Student', email: 'emailuniquegreat@yahoo.com', password: '12345678', password_confirmation: '12345678', first_name: 'first', last_name: 'last' }
		expect(body['user']['type']).to eq('Student')
		expect(body['user']['last_name']).to eq('last')
	end

	it 'returns errors for each user type' do
		post :create, params: { type: 'Lecturer', email: 'emailuniquegreat@yahoo.com', password: '12345678', password_confirmation: '12345678', first_name: 'first', last_name: 'last', position: 'someone' }
		expect(errors['university'].first).to eq("can't be blank")

		post :create, params: { type: 'Student', email: 'anotheremailunique@yahoo.com', password: '12345678', password_confirmation: '12345678', first_name: 'first', last_name: 'last', position: 'someone' }
		expect(errors['position'].first).to eq("must be blank")
	end
end

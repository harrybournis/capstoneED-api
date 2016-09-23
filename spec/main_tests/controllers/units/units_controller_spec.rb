require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::UnitsController, type: :controller do

	describe 'GET index' do

		context 'valid request' do

			before(:each) do
				@controller = V1::UnitsController.new
				@user = FactoryGirl.build(:lecturer_with_units).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			end

			it "returns only the current user's units" do
				expect(@user.units.length).to eq(2)
				unit1 = FactoryGirl.create(:unit)
				unit2 = FactoryGirl.create(:unit)

				get :index
				expect(response.status).to eq(200)
				expect(parse_body['units'].length).to eq(2)
			end
		end
	end

	describe "GET show" do

		before(:each) do
			@controller = V1::UnitsController.new
			@user = FactoryGirl.build(:lecturer_with_units).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it "returns the unit if if is is one of the lectuer's units" do
			get :show, params: { id: @user.units.first.id }
			expect(response.status).to eq(200)
			expect(parse_body['unit']['id']).to eq(@user.units.first.id)
		end

		it 'responds with 403 if unit does not belong to lecturer' do
			new_unit = FactoryGirl.create(:unit)
			get :show, params: { id: new_unit.id }
			expect(response.status).to eq(403)
			expect(parse_body['errors']['base'].first).to eq("This Unit is not associated with the current user")
		end

		it 'responds with 403 if record is not found at all' do
			get :show, params: { id: '3333df' }
			expect(response.status).to eq(403)
			expect(parse_body['errors']['base'].first).to eq("This Unit is not associated with the current user")
		end
	end

	describe 'PATCH update' do

		before(:each) do
			@controller = V1::UnitsController.new
			@user = FactoryGirl.build(:lecturer_with_units).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it 'updates successfully if user is Lecturer and the owner' do
			patch :update, params: { id: @user.units.first.id, name: 'different', code: 'different' }
			expect(response.status).to eq(200)
			expect(parse_body['unit']['name']).to eq('different')
		end

		it 'assigns different department if department_id in params' do
			department = FactoryGirl.create(:department)
			patch :update, params: { id: @user.units.first.id, department_id: department.id }
			expect(response.status).to eq(200)
			@user.reload
			expect(@user.units.first.department_id).to eq(department.id)
		end

		it 'creates a new department if department_attributes in params' do
			expect {
				patch :update, params: { id: @user.units.first.id, department_attributes: { name: 'departmentname', university: 'university' } }
			}.to change { Department.all.count }.by(1)
			expect(response.status).to eq(200)
			@user.reload
			expect(@user.units.first.department.name).to eq('departmentname')
		end

		it 'assigns the department_id if both department_id and department_attributes' do
			department = FactoryGirl.create(:department)
			expect {
				patch :update, params: { id: @user.units.first.id, department_id: department.id, department_attributes: { name: 'departmentname', university: 'university' } }
			}.to_not change { Department.all.count }
			expect(response.status).to eq(200)
			@user.reload
			expect(@user.units.first.department.name).to eq(department.name)
		end
	end

	describe 'DELETE destroy' do

		it 'delete the unit if user is lecturer and owner' do
			@controller = V1::UnitsController.new
			@user = FactoryGirl.build(:lecturer_with_units).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			delete :destroy, params: { id: @user.units.first.id }
			expect(response.status).to eq(204)
		end
	end
end
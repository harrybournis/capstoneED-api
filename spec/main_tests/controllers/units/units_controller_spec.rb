require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe V1::UnitsController, type: :controller do

	describe 'GET index' do

		context 'valid request' do

			before(:each) do
				@controller = V1::UnitsController.new
				@user = FactoryBot.build(:lecturer_with_units).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			end

			it "returns only the current user's units", { docs?: true } do
				expect(@user.units.length).to eq(2)
				unit1 = FactoryBot.create(:unit)
				unit2 = FactoryBot.create(:unit)

				get :index
				expect(status).to eq(200)
				expect(parse_body['units'].length).to eq(2)
			end

			it "returns only the active units" do
				expect(@user.units.length).to eq(2)
				unit = @user.units.first

				unit.archived_at = Date.today
				expect(unit.save).to be_truthy

				get :index
				expect(status).to eq(200)
				expect(body['units'].length).to eq(1)
			end
		end
	end

	describe 'GET index archived' do

		context 'valid request' do

			before(:each) do
				@controller = V1::UnitsController.new
				@user = FactoryBot.build(:lecturer_with_units).process_new_record
				@user.save
				mock_request = MockRequest.new(valid = true, @user)
				request.cookies['access-token'] = mock_request.cookies['access-token']
				request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
			end

			it "returns only the archived units units", { docs?: true } do
				@user.units << FactoryBot.create(:unit)
				expect(@user.units.length).to eq(3)
				unit = @user.units.first
				unit2 = @user.units.second

				unit.archived_at = Date.today
				expect(unit.save).to be_truthy
				unit2.archived_at = Date.today
				expect(unit2.save).to be_truthy

				get :index_archived
				expect(status).to eq(200)
				expect(body['units'].length).to eq(2)
			end

			it 'returns 204 no content if no archived units', { docs?: true } do
				expect(@user.units.length).to eq(2)
				unit = @user.units.first

				get :index_archived
				expect(status).to eq(204)
			end
		end
	end

	describe "GET show" do

		before(:each) do
			@controller = V1::UnitsController.new
			@user = FactoryBot.build(:lecturer_with_units).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it "returns the unit if if is is one of the lectuer's units", { docs?: true } do
			get :show, params: { id: @user.units.first.id }
			expect(status).to eq(200)
			expect(parse_body['unit']['id']).to eq(@user.units.first.id)
		end

		it 'responds with 403 if unit does not belong to lecturer' do
			new_unit = FactoryBot.create(:unit)
			get :show, params: { id: new_unit.id }
			expect(status).to eq(403)
			expect(errors['base'].first).to eq("This Unit is not associated with the current user")
		end

		it 'responds with 403 if record is not found at all' do
			get :show, params: { id: '3333df' }
			expect(status).to eq(403)
			expect(errors['base'].first).to eq("This Unit is not associated with the current user")
		end
	end

	describe 'PATCH update' do

		before(:each) do
			@controller = V1::UnitsController.new
			@user = FactoryBot.build(:lecturer_with_units).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it 'updates successfully if user is Lecturer and the owner', { docs?: true } do
			patch :update, params: { id: @user.units.first.id, name: 'different', code: 'different' }
			expect(status).to eq(200)
			expect(parse_body['unit']['name']).to eq('different')
		end

		it 'assigns different department if department_id in params' do
			department = FactoryBot.create(:department)
			patch :update, params: { id: @user.units.first.id, department_id: department.id }
			expect(status).to eq(200)
			@user.reload
			expect(@user.units.first.department_id).to eq(department.id)
		end

		it 'creates a new department if department_attributes in params' do
			expect {
				patch :update, params: { id: @user.units.first.id, department_attributes: { name: 'departmentname', university: 'university' } }
			}.to change { Department.all.count }.by(1)
			expect(status).to eq(200)
			@user.reload
			expect(@user.units.first.department.name).to eq('departmentname')
		end

		it 'assigns the department_id if both department_id and department_attributes' do
			department = FactoryBot.create(:department)
			expect {
				patch :update, params: { id: @user.units.first.id, department_id: department.id, department_attributes: { name: 'departmentname', university: 'university' } }
			}.to_not change { Department.all.count }
			expect(status).to eq(200)
			@user.reload
			expect(@user.units.first.department.name).to eq(department.name)
		end
	end

	describe 'DELETE destroy' do

		it 'delete the unit if user is lecturer and owner' do
			@controller = V1::UnitsController.new
			@user = FactoryBot.build(:lecturer_with_units).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

			delete :destroy, params: { id: @user.units.first.id }
			expect(status).to eq(204)
		end
	end

	describe 'PATCH archive' do

		before(:each) do
			@controller = V1::UnitsController.new
			@user = FactoryBot.build(:lecturer_with_units).process_new_record
			@user.save
			mock_request = MockRequest.new(valid = true, @user)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		it 'responds with 200 if unit was archived successfully', { docs?: true } do
			unit = @user.units.first

			patch :archive, params: { id: unit.id }

			expect(status).to eq(200)
			expect(body['unit']['archived_at']).to be_truthy
		end

		it 'responds with 422 unprocessable_entity if unit already archived', { docs?: true } do
			unit = @user.units.first
			expect(unit.archive).to be_truthy

			patch :archive, params: { id: unit.id }

			expect(status).to eq(422)
			expect(errors['unit'][0]).to include "has already been archived"
		end

		it 'responds with 403 forbidden if unit not associated' do
			unit = FactoryBot.create(:unit)

			patch :archive, params: { id: unit.id }

			expect(status).to eq(403)
			expect(errors['base'][0]).to include "not associated"
		end
	end
end

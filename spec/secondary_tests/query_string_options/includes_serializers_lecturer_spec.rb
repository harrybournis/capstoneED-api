require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe 'Includes', type: :controller do

	context 'Lecturer' do

		before(:all) do
			@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
			@lecturer.save
			@lecturer.confirm
			@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
			@assignment = FactoryGirl.create(:assignment_with_projects, unit: @unit, lecturer: @lecturer)
			3.times { create :students_project, student: create(:student), project: @assignment.projects[0] }
			expect(@assignment.projects.length).to eq(2)
			expect(@assignment.projects.first.students.length).to eq(3)
		end

		before(:each) do
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'Assignments' do

			before(:each) do
				@controller = V1::AssignmentsController.new
			end

			it 'returns only the specified resource in includes' do
				get :show, params: { id: @assignment.id }
				body_assignment = body['assignment']
				expect(response.status).to eq(200) #1
				expect(body_assignment).to include('end_date', 'start_date')
				expect(body_assignment['projects']).to be_falsy
				expect(body_assignment['projects']).to be_falsy

				get :show, params: { id: @assignment.id, includes: 'projects'}
				body_assignment = body['assignment']
				expect(response.status).to eq(200) #2
				expect(body_assignment['projects']).to be_truthy
				expect(body_assignment['unit']).to be_falsy

				get :show, params: { id: @assignment.id, includes: 'projects,unit'}
				body_assignment = body['assignment']
				expect(response.status).to eq(200) #3
				expect(body_assignment['projects']).to be_truthy
				expect(body_assignment['unit']).to be_truthy
			end

			it 'returns the resource full but only the associations ids if ?compact=true' do
				get :show, params: { id: @assignment.id }
				body_assignment = body['assignment']
				expect(response.status).to eq(200)
				expect(body_assignment).to include('end_date', 'start_date')
				expect(body_assignment['projects']).to be_falsy
				expect(body_assignment['unit']).to be_falsy

				get :show, params: { id: @assignment.id, includes: 'projects', compact: true}
				body_assignment = body['assignment']
				expect(response.status).to eq(200)
				expect(body_assignment['projects']).to be_truthy
				expect(body_assignment['projects'].first.keys.size).to be < 6
				expect(body_assignment['unit']).to be_falsy

				get :show, params: { id: @assignment.id, includes: 'projects,unit'}
				body_assignment = body['assignment']
				expect(response.status).to eq(200)
				expect(body_assignment['projects']).to be_truthy
				expect(body_assignment['projects'].first.keys.size).to be > 6
				expect(body_assignment['unit']).to be_truthy
				expect(body_assignment['unit']).to include('code', 'semester')
			end

			it 'is invalid if * is in the includes' do
				get :show, params: { id: @assignment.id, includes: 'projects,*' }
				expect(status).to eq(400)
				expect(body['errors']['base'][0]).to include("Invalid 'includes' parameter")
			end

			it 'works for index' do
				get :index, params: { includes: 'unit' }
				expect(response.status).to eq(200)
				expect(body['assignments'].first['unit']).to be_truthy
				expect(body['assignments'].first['projects']).to be_falsy
			end

			it 'renders empty array if no collection is empty' do
				@unit.assignments.destroy_all
				expect(@unit.projects.empty?).to be_truthy
				get :index, params: { unit_id: @unit.id, includes: 'lecturer' }
				expect(response.status).to eq(204)
				expect(response.body.empty?).to be_truthy
			end

			it 'renders no associations if includes emtpy string?' do
				get :show, params: { id: @assignment.id, includes: "" }
				expect(body['assignment']['unit']).to be_falsy
				expect(body['assignment']['projects']).to be_falsy
			end

			it 'includes iterations' do
				3.times { FactoryGirl.create(:iteration, assignment_id: @assignment.id) }
				expect {
					get :show, params: { id: @assignment.id, includes: 'iterations,students' }
				}.to make_database_queries(count: 1)
				expect(status).to eq(200)
				expect(body['assignment']['iterations'].length).to eq(@assignment.iterations.length)
				expect(body['assignment']['iterations'][0]['name']).to eq(Iteration.find(body['assignment']['iterations'][0]['id']).name)
				expect(body['assignment']['students'].length).to eq(@assignment.students.length)
			end

			it 'includes iterations in chronological order' do
				3.times { FactoryGirl.create(:iteration, assignment_id: @assignment.id) }

				get :show, params: { id: @assignment.id, includes: 'iterations,students' }

				expect(status).to eq(200)
				expect(body['assignment']['iterations'].length).to eq(@assignment.iterations.length)

				for i in 0..body['assignment']['iterations'].length
					if iteration = body['assignment']['iterations'][i + 1]
						prev_ = DateTime.parse(body['assignment']['iterations'][i]['start_date']).to_i
						next_ = DateTime.parse(body['assignment']['iterations'][i + 1]['start_date']).to_i
						expect(prev_).to be <= next_
					end
				end
			end

			it 'includes pa_forms' do
				iteration1 = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
				iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
				pa_form = FactoryGirl.create(:pa_form, iteration: iteration1)
				pa_form2 = FactoryGirl.create(:pa_form, iteration: iteration2)

				expect {
					get :show, params: { id: @assignment.id, includes: 'iterations' }
				}.to make_database_queries(count: 1)
				expect(status).to eq(200)
				expect(body['assignment'])
			end

			it 'index_with_unit works with includes' do
				get :index_with_unit, params: { unit_id: @unit.id, includes: 'unit,iterations' }

				expect(status).to eq(200)
			end

			it 'included projects have team_points and team_average' do
				get :show, params: { id: @assignment.id, includes: 'projects'}
				body_assignment = body['assignment']
				expect(response.status).to eq(200)
				expect(body_assignment['projects'][0]['team_points']).to be_truthy
				expect(body_assignment['projects'][0]['team_average']).to be_truthy
			end
		end

		describe 'Units' do
			before(:each) do
				@controller = V1::UnitsController.new
			end

			it 'GET show contains assignments' do
				get :show, params: { id: @unit.id }
				expect(body['unit']['assignments']).to be_falsy

				get :show, params: { id: @unit.id, includes: 'assignments' }
				expect(body['unit']['assignments']).to be_truthy
			end

			it 'GET index contains the assignments compact' do
				get :index, params: { includes: 'assignments', compact: true }
				expect(body['units'].first['assignments'].first).to_not include('description')
				expect(body['units'].first['assignments'].first.length).to eq(2)
				expect(body['units'].first['assignments'].first.keys).to include('id')
				expect(body['units'].first['assignments'].first.keys).to include('name')
			end

			it 'GET index contains department compact' do
				get :index, params: { includes: 'department', compact: true }
				expect(body['units'][0]['department']).to be_truthy
			end
		end

		describe 'Projects' do
			before(:each) do
				@controller = V1::ProjectsController.new
			end

			it 'GET show contains students', { docs?: true } do
				get :show, params: { id: @assignment.projects.first.id }
				expect(status).to eq(200)
				expect(body['project']['enrollment_key']).to be_truthy

				@assignment.projects[0].students_projects.offset(1).each { |s| s.nickname = "wolverine#{rand(1000).to_s}"; s.save }

				get :show, params: { id: @assignment.projects[0].id, includes: 'students' }
				expect(status).to eq(200)
				expect(body['project']['students'].length).to eq(@assignment.projects.first.students.length)
			end

			it 'GET index contains students and project compact' do
				get :index_with_assignment, params: { assignment_id: @assignment.id, includes: 'students,assignment', compact: true }
				expect(status).to eq(200)
				body['projects'].each do |project|
					unless project["students"].empty?
						expect(project['students'].first['first_name']).to be_falsy
						expect(project['students'].first['provider']).to be_falsy
						expect(project['assignment']).to_not include('description')
						expect(project['assignment']['id']).to eq(@assignment.id)
						expect(project['lecturer']).to be_falsy
					end
				end
			end

			it 'GET index compact contains unit with name and id only' do
				get :index, params: { includes: 'unit,assignment', compact: true }
				expect(status).to eq(200)

				expect(body['projects'][0]['unit'].length).to eq(2)
				expect(body['projects'][0]['unit'].keys).to include('name')
				expect(body['projects'][0]['unit'].keys).to include('id')

				expect(body['projects'][0]['assignment'].length).to eq(2)
				expect(body['projects'][0]['assignment'].keys).to include('name')
				expect(body['projects'][0]['assignment'].keys).to include('id')
			end
		end

		describe 'Iteration' do
			before(:each) do
				@controller = V1::IterationsController.new
			end

			it 'GET index includes pa_form' do
				iteration = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
				iteration2 = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
				pa_form = FactoryGirl.create(:pa_form, iteration: iteration)
				pa_form2 = FactoryGirl.create(:pa_form, iteration: iteration2)

				get :index, params: { assignment_id: @assignment.id, includes: 'pa_form' }
				expect(status).to eq(200)
				expect(body['iterations'].length).to eq(2)
				expect(body['iterations'][1]['pa_form']).to be_truthy
			end

			it 'GET show includes pa_form' do
				iteration = FactoryGirl.create(:iteration, assignment_id: @assignment.id)
				pa_form = FactoryGirl.create(:pa_form, iteration: iteration)

					get :show, params: { id: iteration.id }
				expect(status).to eq(200)
				expect(body['iteration']['pa_form']).to be_truthy
			end
		end

		describe 'Peer Assessment' do
			before do
				@iteration = FactoryGirl.create(:iteration, assignment: @assignment)
				@pa_form  = FactoryGirl.create(:pa_form, iteration: @iteration)
				@peer_assessment = FactoryGirl.create(:peer_assessment, pa_form: @pa_form)
				@controller = V1::PeerAssessmentsController.new
			end

			it 'index works with includes' do
				get :index, params: { pa_form_id: @pa_form.id, includes: 'submitted_by,submitted_for' }

				expect(status).to eq(200)
			end

			it 'GET show includes pa_form submitted_for submitted_by' do
				get :show, params: { id: @peer_assessment.id, includes: 'submitted_by,pa_form,submitted_for' }
				expect(status).to eq(200)
				expect(body['peer_assessment']['submitted_for']['first_name']).to eq(@peer_assessment.submitted_for.first_name)
				expect(body['peer_assessment']['submitted_for']['last_name']).to eq(@peer_assessment.submitted_for.last_name)
				expect(body['peer_assessment']['submitted_by']['first_name']).to eq(@peer_assessment.submitted_by.first_name)
				expect(body['peer_assessment']['submitted_by']['last_name']).to eq(@peer_assessment.submitted_by.last_name)
			end

			it 'returns peer assessment if associated including the PAForm' do
				get :show, params: { id: @peer_assessment.id, includes: 'pa_form' }
				expect(status).to eq(200)
				expect(body['peer_assessment']['pa_form']).to be_truthy
			end
		end
	end
end

require 'rails_helper'
include JWTAuth::JWTAuthenticator

RSpec.describe 'Includes', type: :controller do

	context 'Lecturer' do

		before(:all) do
			@lecturer = FactoryGirl.build(:lecturer_with_password).process_new_record
			@lecturer.save
			@lecturer.confirm
			@unit = FactoryGirl.create(:unit, lecturer: @lecturer)
			@project = FactoryGirl.create(:project_with_teams, unit: @unit, lecturer: @lecturer)
			3.times { @project.teams.first.students << FactoryGirl.build(:student) }
			expect(@project.teams.length).to eq(2)
			expect(@project.teams.first.students.length).to eq(3)
		end

		before(:each) do
			mock_request = MockRequest.new(valid = true, @lecturer)
			request.cookies['access-token'] = mock_request.cookies['access-token']
			request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']
		end

		describe 'Projects' do

			before(:each) do
				@controller = V1::ProjectsController.new
			end

			context 'Valid' do

				it 'makes only on query for teams and unit' do
					expect {
						get :show, params: { id: @project.id }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200) #1

					expect {
						get :show, params: { id: @project.id, includes: 'teams,unit' }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200) #2

					expect {
						get :show, params: { id: @project.id, includes: 'teams', compact: true }
					}.to make_database_queries(count: 1)
					expect(status).to eq(200)
				end
			end

			context 'invalid' do
				it 'should render errors for invalid includes params' do
					expect {
						get :show, params: { id: @project.id, includes: 'teams,unit,lecturer,banana' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400) #1
					expect(body['errors']['base'].first).to eq("Invalid 'includes' parameter. Project resource accepts only: lecturer, unit, teams, students. Received: teams,unit,lecturer,banana.")

					expect {
						get :show, params: { id: @project.id, includes: 'teams,unit,lecturer,banana,manyother,wrong_params,$@^&withsymbols,*,**' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400) #1
					expect(body['errors']['base'].first).to eq("Invalid 'includes' parameter. Project resource accepts only: lecturer, unit, teams, students. Received: teams,unit,lecturer,banana,manyother,wrong_params,$@^&withsymbols,*,**.")

					expect {
						get :show, params: { id: @project.id, includes: '*,**' }
					}.to make_database_queries(count: 0)
					expect(status).to eq(400) #1
					expect(body['errors']['base'].first).to eq("Invalid 'includes' parameter. Project resource accepts only: lecturer, unit, teams, students. Received: *,**.")
				end
			end

			# it 'benchmark' do
			# 	ass_sym = [:lecturer, :unit, :teams, :students]
			# 	ass_sym_set = [:lecturer, :unit, :teams, :students].to_set
			# 	ass_str = ['lecturer', 'unit', 'teams', 'students']
			# 	ass_str_set = ['lecturer', 'unit', 'teams', 'students'].to_set
			# 	incl_sym = [:teams, :unit]
			# 	incl_sym_set = [:teams, :unit].to_set
			# 	incl_str = ['teams', 'unit']
			# 	incl_str_set = ['teams', 'unit'].to_set

			# 	input = "teams,unit,banana,enemy"
			# 	Benchmark.ips do |x|
			# 		x.iterations = 15
			# 		x.report('symbol array')	do
			# 			array = input.split(',')
			# 			unless array.length > ass_str_set.length
			# 				incl_sym_set = Set.new(array.map { |s| s.to_sym })
			# 				if incl_sym_set.subset? ass_sym_set
			# 					project = Project.where(id: 1, lecturer_id: 32).eager_load(array)[0]
			# 				else
			# 					false
			# 				end
			# 			end
			# 		end
			# 		x.report('string array') do
			# 			array = input.split(',')
			# 			unless array.length > ass_str_set.length
			# 				incl_str_set = Set.new(array)
			# 				if incl_str_set.subset? ass_str_set
			# 					project = Project.where(id: 1, lecturer_id: 32).eager_load(array)[0]
			# 				else
			# 					false
			# 				end
			# 			end
			# 		x.report('string array no set') do
			# 			array = input.split(',')
			# 			unless array.length > ass_str_set.length
			# 				res = true
			# 				array.each { |e| res = false unless ass_str.include? e }
			# 				if res
			# 					project = Project.where(id: 1, lecturer_id: 32).eager_load(array)[0]
			# 				else
			# 					false
			# 				end
			# 			end
			# 		end
			# 		x.compare!
			# 	end
			# end
		end

		describe 'Units' do
			before(:each) do
				@controller = V1::UnitsController.new
			end

			# it 'GET show contains projects' do
			# 	get :show, params: { id: @unit.id }
			# 	expect(parse_body['unit']['projects']).to be_falsy

			# 	get :show, params: { id: @unit.id, includes: 'projects' }
			# 	expect(parse_body['unit']['projects']).to be_truthy
			# end

			# it 'GET index contains the projects compact' do
			# 	get :index, params: { includes: 'projects', compact: true }
			# 	expect(parse_body['units'].first['projects'].first).to_not include('description')
			# end
		end

		describe 'Teams' do
			before(:each) do
				@controller = V1::TeamsController.new
			end

			# it 'GET show contains students' do
			# 	get :show, params: { id: @project.teams.first.id }
			# 	expect(status).to eq(200)
			# 	expect(body['team']['enrollment_key']).to be_truthy

			# 	get :show, params: { id: @project.teams.first.id, includes: 'students' }
			# 	expect(status).to eq(200)
			# 	expect(body['team']['students'].length).to eq(@project.teams.first.students.length)
			# end

			# it 'GET index contains students and project compact' do
			# 	get :index, params: { project_id: @project.id, includes: 'students,project,lecturer', compact: true }
			# 	expect(status).to eq(200)
			# 	expect(body['teams'].first['students'].first).to_not include('email', 'provider')
			# 	expect(body['teams'].first['project']).to_not include('description')
			# 	expect(body['teams'].first['project']['id']).to eq(@project.id)
			# 	expect(body['teams'].first['lecturer']).to be_falsy
			# end
		end

		# describe 'Departments' do
		# 	before(:each) do
		# 		@controller = V1::DepartmentsController.new
		# 		@department = Department.first
		# 	end

		# 	it 'contains units' do
		# 		get :index, params: { id: @department.id }
		# 		expect(status).to eq(200)
		# 		expect(body['departments'].first['enrollment_key']).to be_truthy

		# 		get :index, params: { id: @department, includes: 'units' }
		# 		expect(status).to eq(200)
		# 		expect(body['departments'].first['units'].length).to eq(@department.units.length)
		# 		expect(body['departments'].first['units'].first).to include('code','semester')

		# 		get :index, params: { id: @department.id }
		# 		expect(status).to eq(200)
		# 		expect(body['departments'].first['units'].first['id']).to eq(@department.units.first.id)
		# 		expect(body['departments'].first['units'].first).to_not include('code','semester')
		# 	end
		# end
	end


end

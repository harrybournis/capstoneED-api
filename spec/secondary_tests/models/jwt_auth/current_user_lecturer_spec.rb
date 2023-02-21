require 'rails_helper'
require 'helpers/mock_request.rb'
include JWTAuth::JWTAuthenticator

RSpec.describe JWTAuth::CurrentUserLecturer, type: :model do

  describe 'Assignments' do

    before(:each) do
      @user = FactoryBot.create(:lecturer)
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      @unit = FactoryBot.create(:unit, lecturer: @user)
      @assignment = FactoryBot.create(:assignment_with_projects, unit: @unit, lecturer: @user)
      3.times { create :students_project, student: create(:student), project: @assignment.projects[0] }#@assignment.projects.first.students << FactoryBot.build(:student) }
    end

    it 'loads the correct assignments' do
      expect {
        (@assignments = @current_user.assignments).length
      }.to make_database_queries(count: 1)
      expect(@assignments.length).to eq(@current_user.load.assignments.length)
    end

    it 'includes associations' do
      expect {
        @assignments.length if @assignments = @current_user.assignments(includes: 'unit')
      }.to make_database_queries(count: 1)
      expect {
        @assignments[0].unit
      }.to_not make_database_queries

      expect {
        (@assignments = @current_user.assignments(includes: ['unit','projects'])).length
      }.to make_database_queries(count: 1)
      expect {
        @assignments[0].projects
      }.to_not make_database_queries
      expect {
        @assignments[0].unit
      }.to_not make_database_queries

      expect {
        (@assignments = @current_user.assignments(includes: ['lecturer','projects','students'])).length
      }.to make_database_queries(count: 1)
      expect {
        @assignments[0].lecturer
      }.to_not make_database_queries
      expect {
        @assignments[0].projects[0].students
      }.to_not make_database_queries
    end

    it 'can chain queries' do
      expect {
        @assignment_find[0].unit if (@assignment_find = @current_user.assignments(includes: 'unit').where(unit_id: @unit)).length > 0
      }.to make_database_queries(count: 1)
      expect(@assignment_find[0].unit).to eq(@unit)
    end
  end

  describe 'Units' do
    before(:each) do
      @user = FactoryBot.create(:lecturer)
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      @other_unit = FactoryBot.create(:unit)
      @unit = FactoryBot.create(:unit, lecturer: @user)
      @assignment = FactoryBot.create(:assignment_with_projects, unit: @user.units[0], lecturer: @user)
      3.times { create :students_project, student: create(:student), project: @assignment.projects[0] }#@assignment.projects.first.students << FactoryBot.build(:student) }
    end

    it 'loads the correct units' do
      @units = @current_user.units
      res = true
      @units.each { |u| res = false unless @user.units.include? u }
      expect(res).to be_truthy
    end

    it 'returns the units with includes without additional database queries' do
      expect {
        (@units = @current_user.units(includes: ['lecturer','department'])).length
      }.to make_database_queries(count: 1)
      expect {
        @units[0].lecturer
      }.to_not make_database_queries
      expect {
        @units[0].department
      }.to_not make_database_queries

      expect {
        (@units = @current_user.units(includes: 'assignments')).length
      }.to make_database_queries(count: 1)
      expect {
        @units[0].assignments[0].start_date
      }.to_not make_database_queries
    end
  end

  describe 'Questions' do
    before(:each) do
      @user = FactoryBot.create(:lecturer)
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      5.times { @user.questions << FactoryBot.build(:question) }
      expect(@user.questions.count).to eq(5)
    end

    it 'should make one database query' do
      expect {
        (@questions = @current_user.questions).length
      }.to make_database_queries(count: 1)
      expect(@questions.length).to eq(5)
    end
  end

  describe 'Departments' do
    it 'returns correct number of departments' do
      @user = FactoryBot.create(:lecturer)
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      2.times { FactoryBot.create(:unit, lecturer_id: @user.id) }

      expect(@current_user.departments.length).to eq(2)
    end
  end

  describe 'PaForms' do
    it 'returns correct pa_forms' do
      @user = FactoryBot.create(:lecturer)
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      @unit = FactoryBot.create(:unit, lecturer: @user)
      @assignment = FactoryBot.create(:assignment_with_projects, unit: @unit, lecturer: @user)

      iteration = FactoryBot.create(:iteration, assignment: @assignment)
      iteration2 = FactoryBot.create(:iteration, assignment: @assignment)
      pa_form = FactoryBot.create(:pa_form, iteration: iteration)
      pa_form2 = FactoryBot.create(:pa_form, iteration: iteration2)
      expect(@current_user.pa_forms.length).to eq(2)
    end
  end

  describe "Peer Assessment" do
    it 'returns the associated peer assessments' do
      @user = FactoryBot.create(:lecturer_confirmed)
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      unit = FactoryBot.create(:unit, lecturer_id: @user.id)
      assignment = FactoryBot.create(:assignment, lecturer_id: @user.id, unit: unit)
      iteration  = FactoryBot.create(:iteration, assignment: assignment)
      pa_form = FactoryBot.create(:pa_form, iteration: iteration)
      project = FactoryBot.create(:project, assignment: assignment)
      student = FactoryBot.create(:student_confirmed)
      student2 = FactoryBot.create(:student_confirmed)
      student3 = FactoryBot.create(:student_confirmed)
      #project.students << student
      #project.students << student2
      #project.students << student3
      create :students_project, student: student, project: project
      create :students_project, student: student2, project: project
      create :students_project, student: student3, project: project
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: student, submitted_for: student2)
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: student, submitted_for: student3)
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: student2, submitted_for: student)
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: student2, submitted_for: student3)
      peer_assessment_irrellevant = FactoryBot.create(:peer_assessment_with_callback)

      expect(@current_user.peer_assessments.length).to eq(4)
    end
  end

  describe 'Extension' do
    it 'returns the associated extensions' do
      @user = get_lecturer_with_units_assignments_projects
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      assignment = @user.assignments[0]
      iteration = FactoryBot.create(:iteration, assignment: assignment)
      pa_form = FactoryBot.create(:pa_form, iteration_id: iteration.id)
      project = @user.assignments[0].projects[0]
      extension = FactoryBot.create(:extension, project_id: project.id, deliverable_id: pa_form.id)
      extension_other = FactoryBot.create(:extension)
      expect(@current_user.extensions.length).to eq(1)
      expect(@current_user.extensions[0]).to eq(extension)
    end
  end

  describe 'Project Evalutions' do
    it 'returns the associated Project Evaluations' do
      @user = get_lecturer_with_units_assignments_projects
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      @project = @user.projects.first
      now = DateTime.now
      @project.assignment.start_date = now
      @project.assignment.end_date = now + 1.month
      @project.assignment.save
      create :iteration, assignment: @project.assignment
      feeling = FactoryBot.create(:feeling)

      now = DateTime.now
      assignment = @user.assignments.first
      assignment.start_date = now
      assignment.end_date = now + 1.month
      assignment.save
      project = assignment.projects.first
      project2 = assignment.projects.last
      iteration = FactoryBot.create(:iteration, assignment: assignment, start_date: now, deadline: now + 28.days)

      attr = FactoryBot.attributes_for(:project_evaluation).merge(user_id: @user.id, iteration_id: iteration.id, project_id: project.id, feelings_average:  38)
      pe = ProjectEvaluation.create(attr)
      attr = FactoryBot.attributes_for(:project_evaluation).merge(user_id: @user.id, iteration_id: iteration.id, project_id: project2.id, feelings_average:  38)

      pe = ProjectEvaluation.create(attr)

      FactoryBot.create(:project_evaluation)

      expect(ProjectEvaluation.all.size).to eq(3)
      expect(@current_user.project_evaluations.length).to eq(2)
    end
  end

  describe 'projects' do
    it "are the same as the user's" do
      @user = get_lecturer_with_units_assignments_projects
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      @user.units.first.archive
      expect(@user.projects.active.count).to eq(@current_user.projects.active.count)

      expect(create :project).to be_truthy
      expect(@user.projects.active.count).to eq(@current_user.projects.active.count)
    end
  end

  describe 'form_templates' do
    it 'returns form_templates of the lecturer' do
      @lecturer = create :lecturer_confirmed
      2.times { create(:form_template, lecturer: @lecturer) }
      expect(@lecturer.form_templates.length).to eq 2
      @request = MockRequest.new(valid = true,@lecturer)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)
      expect(@current_user.form_templates).to eq @lecturer.form_templates
    end
  end

  describe 'Iteration' do
    it 'returns the current iterations for the current user ' do
      now = DateTime.now
      @lecturer = FactoryBot.create(:lecturer_confirmed)
      @request = MockRequest.new(valid = true, @lecturer)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      unit = create :unit, lecturer: @lecturer
      assignment  = create :assignment, unit: unit, lecturer: @lecturer, start_date: now - 2.months, end_date:  now + 2.months
      assignment2  = create :assignment,  start_date: now - 2.months, end_date:  now + 2.months
      iteration1 = create :iteration, start_date: now - 1.month, deadline: now - 10.days, assignment: assignment
      iteration2 = create :iteration, start_date: now - 1.hour, deadline: now + 10.days, assignment: assignment
      iteration3 = create :iteration, start_date: now - 30.minutes, deadline: now + 20.days, assignment: assignment2
      expect(Iteration.count).to eq 3
      expect(@current_user.iterations_active.length).to eq 1
      expect(@current_user.iterations_active.first).to eq iteration2
    end
  end

  describe 'scored iterations' do
    it 'returns the scored iterations' do
      @lecturer = FactoryBot.create(:lecturer_confirmed)
      @request = MockRequest.new(valid = true, @lecturer)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserLecturer.new(@token_id, 'Lecturer', @device)

      unit = create :unit, lecturer: @lecturer
      assignment = create :assignment, lecturer: @lecturer, unit: unit
      2.times { create :iteration, assignment: assignment }
      assignment.iterations.first.update(is_scored: true)

      expect(@lecturer.iterations.count).to eq @current_user.iterations.count
      expect(@lecturer.iterations.count).to eq @current_user.scored_iterations.count + 1
    end
  end
end

require 'rails_helper'
require 'helpers/mock_request.rb'
#include JWTAuth::JWTAuth::JWTAuthenticator

RSpec.describe JWTAuth::CurrentUserStudent, type: :model do

  describe 'Assignments' do

    before(:each) do
      @user = FactoryBot.create(:student)
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

      lecturer = FactoryBot.create(:lecturer)
      @unit = FactoryBot.create(:unit, lecturer: lecturer)
      @assignment = FactoryBot.create(:assignment_with_projects, unit: @unit, lecturer: lecturer)
      3.times { create :students_project, student: create(:student), project: @assignment.projects[0] } #@assignment.projects.first.students << FactoryBot.build(:student) }
      #Project.first.students << @user
      create :students_project, student: @user, project: Project.first
      expect(@user.assignments.length).to eq(1)
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
        @assignment_find[0].unit if (@assignment_find = @current_user.assignments(includes: ['unit']).where(unit_id: @unit)).length > 0
      }.to make_database_queries(count: 1)
      expect(@assignment_find[0].unit).to eq(@unit)
    end
  end

  describe 'Units' do
    before(:all) do
      @user = FactoryBot.create(:lecturer)
      @other_unit = FactoryBot.create(:unit)
      @unit = FactoryBot.create(:unit, lecturer: @user)
      @assignment = FactoryBot.create(:assignment_with_projects, unit: @user.units[0], lecturer: @user)
      @game_setting = create :game_setting, assignment: @assignment
    end
    before(:each) do
      @user = FactoryBot.create(:student)
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

      #@assignment.projects.first.students << @user
      create :students_project, student: @user, project: @assignment.projects[0]
    end

    it 'loads the correct units' do
      @units = @current_user.units
      res = true
      @units.each { |u| res = false unless @current_user.units.include? u }
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
        (@units = @current_user.units(includes: ['assignments'])).length
      }.to make_database_queries(count: 1)
      expect {
        @units[0].assignments[0].start_date
      }.to_not make_database_queries
    end
  end

  describe 'PaForms' do

    before do
      @user = FactoryBot.create(:lecturer)
      @student = FactoryBot.create(:student)
      @request = MockRequest.new(valid = true, @student)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

      @unit = FactoryBot.create(:unit, lecturer: @user)
      @assignment = FactoryBot.create(:assignment_with_projects, unit: @unit, lecturer: @user)
      @project = FactoryBot.create(:project, assignment_id: @assignment.id)
      #@project.students << @student
      create :students_project, student: @student, project: @project
    end

    it 'returns correct pa_forms' do
      iteration = FactoryBot.create(:iteration, assignment: @assignment)
      iteration2 = FactoryBot.create(:iteration, assignment: @assignment)
      pa_form = FactoryBot.create(:pa_form, iteration: iteration)
      pa_form2 = FactoryBot.create(:pa_form, iteration: iteration2)

      expect(@current_user.pa_forms.length).to eq(2)
    end

    # it '#pa_forms_active returns only the students active forms' do
    # 	now = DateTime.now
    # 	iteration1 = FactoryBot.create(:iteration, start_date: now + 3.days, deadline: now + 5.days, assignment_id: @assignment.id)
    # 	iteration2 = FactoryBot.create(:iteration, start_date: now + 4.days, deadline: now + 6.days, assignment_id: @assignment.id)
    # 	FactoryBot.create(:pa_form, iteration: iteration1)
    # 	FactoryBot.create(:pa_form, iteration: iteration2)
    # 	irrelevant = FactoryBot.create(:pa_form)
    # 	expect(PaForm.all.length).to eq 3

    # 	Timecop.travel(now + 3.days + 1.minute) do
    # 		expect(@current_user.pa_forms.active.length).to eq 1
    # 	end

    # 	Timecop.travel(now + 4.days + 1.minute) do
    # 		expect(@current_user.pa_forms.active.length).to eq 2
    # 	end

    # 	Timecop.travel(now + 5.days + 1.minute) do
    # 		expect(@current_user.pa_forms.active.length).to eq 1
    # 	end

    # 	Timecop.travel(now + 6.days + 1.minute) do
    # 		expect(@current_user.pa_forms.active.length).to eq 0
    # 	end
    # end
  end

  describe "Peer Assessment" do
    it 'returns the associated peer assessments' do
      @user = FactoryBot.create(:student_confirmed)
      @request = MockRequest.new(valid = true, @user)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

      lecturer = FactoryBot.create(:lecturer_confirmed)
      unit = FactoryBot.create(:unit, lecturer_id: lecturer.id)
      assignment = FactoryBot.create(:assignment, lecturer_id: lecturer.id, unit: unit)
      iteration  = FactoryBot.create(:iteration, assignment: assignment)
      pa_form = FactoryBot.create(:pa_form, iteration: iteration)
      student  = FactoryBot.create(:student_confirmed)
      student2 = FactoryBot.create(:student_confirmed)
      student3 = FactoryBot.create(:student_confirmed)
      project = FactoryBot.create(:project, assignment: assignment)
      #project.students << @user
      #project.students << student
      #project.students << student2
      #project.students << student3
      create :students_project, student: @user, project: project
      create :students_project, student: student, project: project
      create :students_project, student: student2, project: project
      create :students_project, student: student3, project: project
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: @user, submitted_for: student)
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: @user, submitted_for: student2)
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: @user, submitted_for: student3)
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: student, submitted_for: student2)
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: student, submitted_for: student3)
      peer_assessment = FactoryBot.create(:peer_assessment_with_callback, pa_form: pa_form, submitted_by: student, submitted_for: @user)
      peer_assessment_irrellevant = FactoryBot.create(:peer_assessment_with_callback)

      expect(@current_user.peer_assessments_for.length).to eq(1)
      expect(@current_user.peer_assessments_by.length).to eq(3)
      expect(@current_user.peer_assessments.length).to eq(4)
    end
  end

  describe 'Extensions' do

    before do
      @user = FactoryBot.create(:lecturer)
      @student = FactoryBot.create(:student)
      @request = MockRequest.new(valid = true, @student)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

      @unit = FactoryBot.create(:unit, lecturer: @user)
      @assignment = FactoryBot.create(:assignment_with_projects, unit: @unit, lecturer: @user)
      @team = FactoryBot.create(:project, assignment_id: @assignment.id)
      #@team.students << @student
      create :students_project, student: @student, project: @team
    end

    it 'returns the associated extensions' do
      iteration = FactoryBot.create(:iteration, assignment: @assignment)
      iteration2 = FactoryBot.create(:iteration, assignment: @assignment)
      pa_form = FactoryBot.create(:pa_form, iteration: iteration)
      pa_form2 = FactoryBot.create(:pa_form, iteration: iteration2)
      extension = FactoryBot.create(:extension, deliverable_id: pa_form.id, project_id: @team.id)
      extension_other = FactoryBot.create(:extension)

      expect(@current_user.extensions.length).to eq(1)
      expect(@current_user.extensions[0]).to eq(extension)
    end
  end

  describe 'Iterations' do
    it 'iterations_active returns the active iterations' do
      now = DateTime.now
      assignment  = create :assignment,   start_date: now - 2.months, end_date:  now + 2.months
      iteration1 = create :iteration, start_date: now - 1.month, deadline: now - 10.days, assignment: assignment
      iteration2 = create :iteration, start_date: now - 1.hour, deadline: now + 10.days, assignment: assignment
      project = create :project, assignment: assignment
      student = create :student_confirmed
      students_project = create :students_project, student: student, project: project

      @request = MockRequest.new(valid = true, student)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

      expect(@current_user.iterations_active.length).to eq 1
      expect(@current_user.iterations_active.first).to eq iteration2
    end
  end

  describe 'scored_iterations' do
    it 'returns the students scored iterations' do
      score = 0.2
      student = create :student_confirmed
      project = create :project
      create :students_project, student: student, project: project
      iteration = create :iteration, assignment: project.assignment, is_scored: true
      iteration2 = create :iteration, assignment: project.assignment
      iteration_mark = create :iteration_mark, iteration: iteration, student: student, pa_score: score

      @request = MockRequest.new(valid = true, student)
      decoded_token = JWTAuth::JWTAuthenticator.decode_token(@request.cookies['access-token'])
      @token_id = decoded_token.first['id']
      @device = decoded_token.first['device']
      @current_user = JWTAuth::CurrentUserStudent.new(@token_id, 'Student', @device)

      expect(@current_user.scored_iterations.length).to eq 1
    end
  end
end

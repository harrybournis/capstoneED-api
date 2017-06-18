# require 'rails_helper'

# RSpec.describe V1::Iterations::ScoredIterationsController, type: :controller do

#   before :all do
#     @lecturer = create :lecturer_confirmed
#     @unit = FactoryGirl.create(:unit, lecturer: @lecturer)
#     @assignment = FactoryGirl.create(:assignment, lecturer: @lecturer, unit: @unit)
#     @game_setting = create :game_setting, assignment: @assignment
#     @iteration = FactoryGirl.create(:iteration, assignment: @assignment)
#     @pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
#     @student2 = FactoryGirl.create(:student_confirmed)
#     @student3 = FactoryGirl.create(:student_confirmed)
#     @student4 = FactoryGirl.create(:student_confirmed)
#     @student5 = FactoryGirl.create(:student_confirmed)
#     @project = FactoryGirl.create(:project, assignment: @assignment)
#     create :students_project, student: @student, project: @project
#     create :students_project, student: @student2, project: @project
#     create :students_project, student: @student3, project: @project
#     create :students_project, student: @student4, project: @project
#     create :students_project, student: @student5, project: @project

#     Timecop.travel(@iteration.start_date + 1.minute) do
#       @peer_assessment = FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student2)
#       FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student3)
#       FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student4)
#       FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student5)

#       FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student)
#       FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student3)
#       FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student4)
#       FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student5)
#     end
#     CalculatePaScoresService.new(@iteration).call
#   end

#   before(:each) do
#     @controller = V1::Iterations::ScoredIterationsController.new
#     mock_request = MockRequest.new(valid = true, @lecturer)
#     request.cookies['access-token'] = mock_request.cookies['access-token']
#     request.headers['X-XSRF-TOKEN'] = mock_request.headers['X-XSRF-TOKEN']

#   end

#   describe 'index' do
#     it 'returns the students names in columns and rows' do
#       get :index, params: { id: @iteration.id }
#       binding.pry
#     end

# end

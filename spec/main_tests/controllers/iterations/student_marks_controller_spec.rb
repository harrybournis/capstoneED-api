# require 'rails_helper'

# RSpec.describe V1::Iterations::ScoredIterationsController, type: :controller do

#   before :all do
#     @lecturer = create :lecturer_confirmed
#     @unit = FactoryBot.create(:unit, lecturer: @lecturer)
#     @assignment = FactoryBot.create(:assignment, lecturer: @lecturer, unit: @unit)
#     @game_setting = create :game_setting, assignment: @assignment
#     @iteration = FactoryBot.create(:iteration, assignment: @assignment)
#     @pa_form = FactoryBot.create(:pa_form, iteration: @iteration)
#     @student2 = FactoryBot.create(:student_confirmed)
#     @student3 = FactoryBot.create(:student_confirmed)
#     @student4 = FactoryBot.create(:student_confirmed)
#     @student5 = FactoryBot.create(:student_confirmed)
#     @project = FactoryBot.create(:project, assignment: @assignment)
#     create :students_project, student: @student, project: @project
#     create :students_project, student: @student2, project: @project
#     create :students_project, student: @student3, project: @project
#     create :students_project, student: @student4, project: @project
#     create :students_project, student: @student5, project: @project

#     Timecop.travel(@iteration.start_date + 1.minute) do
#       @peer_assessment = FactoryBot.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student2)
#       FactoryBot.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student3)
#       FactoryBot.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student4)
#       FactoryBot.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student5)

#       FactoryBot.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student)
#       FactoryBot.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student3)
#       FactoryBot.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student4)
#       FactoryBot.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student5)
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

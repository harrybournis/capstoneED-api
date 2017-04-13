require 'rails_helper'

RSpec.describe PointsAward::Awarders::PeerAssessmentAwarder, type: :model do

  before :all do
    @student = create :student_confirmed
    @lecturer = create :lecturer_confirmed
    @unit = FactoryGirl.create(:unit, lecturer: @lecturer)
    @assignment = FactoryGirl.create(:assignment, lecturer: @lecturer, unit: @unit)
    @iteration = FactoryGirl.create(:iteration, assignment: @assignment)
    @pa_form = FactoryGirl.create(:pa_form, iteration: @iteration)
    @student2 = FactoryGirl.create(:student_confirmed)
    @student3 = FactoryGirl.create(:student_confirmed)
    @student4 = FactoryGirl.create(:student_confirmed)
    @student5 = FactoryGirl.create(:student_confirmed)
    @project = FactoryGirl.create(:project, assignment: @assignment)
    create :students_project, student: @student, project: @project
    create :students_project, student: @student2, project: @project
    create :students_project, student: @student3, project: @project
    create :students_project, student: @student4, project: @project
    create :students_project, student: @student5, project: @project

    Timecop.travel(@iteration.start_date + 1.minute) do
      @peer_assessment = FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student2)
      FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student3)
      FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student4)

      FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student)
      FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student3)
      FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student4)
      FactoryGirl.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student2, submitted_for: @student5)
    end

    @points_board  = PointsAward::PointsBoard.new(@student, @peer_assessment)
    @awarder = PointsAward::Awarders::PeerAssessmentAwarder.new(@points_board)
  end

  it '#call returns @points_board object with points under the :peer_assessment key' do
    points_board = @awarder.call
    expect(points_board[:peer_assessment]).to be_truthy
    expect(points_board[:peer_assessment]).to_not be_empty
  end
end

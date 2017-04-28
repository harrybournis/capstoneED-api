require 'rails_helper'

RSpec.describe Decorators::PendingProjectEvaluation, type: :model do

  before :each do
    @now = DateTime.now
    @assignment = create :assignment, start_date: @now - 1.day, end_date: @now + 1.day + 1.hour
    @iteration = create :iteration, assignment: @assignment
    @project = create :project, assignment: @assignment
    @student1 = create :student_confirmed
    @student2 = create :student_confirmed
    @sp1 = create :students_project, student: @student1, project: @project
    @sp2 = create :students_project, student: @student2, project: @project
    @pending = Decorators::PendingProjectEvaluation.new(@iteration, @project)
  end

  it 'takes the ProjectEvaluation.NO_OF_EVALUATIONS_PER_ITERATION if parameter is not supplied' do
    expect(@pending.no_of_evaluations_per_iteration).to eq ProjectEvaluation::NO_OF_EVALUATIONS_PER_ITERATION

    pending = Decorators::PendingProjectEvaluation.new(@iteration, @project, 6)
    expect(pending.no_of_evaluations_per_iteration).to eq 6
  end

  it 'raises error if no_of_evaluations_per_iteration is less than 1' do
    expect {
      Decorators::PendingProjectEvaluation.new(@iteration, @project, 0)
    }.to raise_error(ArgumentError)
  end

  it '#pending? returns true if currently during one of the valid submisssion periods' do
    Timecop.travel @iteration.deadline - 2.hours do
      expect(@pending.pending?).to be_truthy
    end

    Timecop.travel @iteration.start_date + 1.minute do
      expect(@pending.pending?).to be_falsy
    end

    expect(@pending.pending?).to be_truthy
  end

  it '#current_submission_range returns the the current submission range if pending?' do
    Timecop.travel @iteration.deadline - 2.hours do
      range = @pending.current_submission_range
      expect(range.cover?(DateTime.now)).to be_truthy
    end

    Timecop.travel @iteration.start_date + 1.minute do
      expect(@pending.current_submission_range).to be_falsy
    end

    range = @pending.current_submission_range
    expect(range.cover?(DateTime.now)).to be_truthy
  end

  it '#team_answers returns all the students in the project' do
    expect(@pending.team_answers.length).to eq 2
  end

  it '#team_answers does not have percent_completed and feelings if they have not completed the project evaluation' do
    expect(create(:project_evaluation, user: @student1, project: @project, iteration: @iteration)).to be_truthy

    expect(@pending.team_answers[0][:percent_completed]).to be_truthy
    expect(@pending.team_answers[1][:percent_completed]).to be_falsy
  end

  it '#team_answers does not include the lecturer' do
    expect(create(:project_evaluation, user: @student1, project: @project, iteration: @iteration)).to be_truthy
    expect(create(:project_evaluation, user: @project.lecturer, project: @project, iteration: @iteration)).to be_truthy

    expect(@pending.team_answers.length).to eq 2
  end
end

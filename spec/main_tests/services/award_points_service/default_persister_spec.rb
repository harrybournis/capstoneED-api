require 'rails_helper'

RSpec.describe PointsAward::Persisters::DefaultPersister, type: :model do

  describe 'PeerAssessmentPoint' do
    before :each do
      @student = create :student_confirmed
      @lecturer = create :lecturer_confirmed
      @unit = FactoryBot.create(:unit, lecturer: @lecturer)
      @assignment = FactoryBot.create(:assignment, lecturer: @lecturer, unit: @unit)
      @iteration = FactoryBot.create(:iteration, assignment: @assignment)
      @pa_form = FactoryBot.create(:pa_form, iteration: @iteration)
      @student2 = FactoryBot.create(:student_confirmed)
      @project = FactoryBot.create(:project, assignment: @assignment)
      create :students_project, student: @student, project: @project
      create :students_project, student: @student2, project: @project

      Timecop.travel(@iteration.start_date + 1.minute) do
        @peer_assessment = FactoryBot.create(:peer_assessment, pa_form: @pa_form, submitted_by: @student, submitted_for: @student2)
      end

      @points_board  = PointsAward::PointsBoard.new(@student, @peer_assessment, @project.id)

      @points_board.add :peer_assessment, { points: 10, reason_id: 1 }
      @points_board.add :peer_assessment, { points: 20, reason_id: 2 }
      @points_board.add :peer_assessment, { points: 30, reason_id: 3 }
      expect(@points_board[:peer_assessment].length).to eq 3
      @persister = PointsAward::Persisters::DefaultPersister.new @points_board
    end

    it 'returns points_board object' do
      points_board = @persister.call
      expect(points_board).to be_a PointsAward::PointsBoard
    end

    # it '#call creates records in the correct table in the database' do
    #   @points_board = PointsBoard.new(student, )
    # end
    it '#call returns PointsBoard with persisted? true and no errors if successful save' do
      board = @persister.call
      expect(board.persisted?).to be_truthy
      expect(board.errors?).to be_falsy
    end

    it '#call creates new PeerAssessmentPoints in database' do
      expect {
        @board = @persister.call
      }.to change { PeerAssessmentPoint.count }.by 3

      expect(@board.persisted?).to be_truthy
      expect(@board.errors?).to be_falsy
    end

    it '#call records saved match the hashes in the points array' do
      @persister.call
      expect(PeerAssessmentPoint.first.points).to eq 10
      expect(PeerAssessmentPoint.first.reason_id).to eq 1
      expect(PeerAssessmentPoint.second.points).to eq 20
      expect(PeerAssessmentPoint.second.reason_id).to eq 2
      expect(PeerAssessmentPoint.third.points).to eq 30
      expect(PeerAssessmentPoint.third.reason_id).to eq 3
    end
  end

  describe 'ProjectEvaluationPoint' do

    before :all do
      @lecturer = get_lecturer_with_units_assignments_projects
      @student = FactoryBot.create(:student)
      @project = @lecturer.projects.first
      create :students_project, student: @student, project: @project
      now = DateTime.now
      @project.assignment.start_date = now
      @project.assignment.end_date = now + 1.month
      @project.assignment.save
      create(:iteration, assignment: @project.assignment)
      @feeling = FactoryBot.create(:feeling)
      @project_evaluation = FactoryBot.create(:project_evaluation, user: @student, project: @project, percent_complete: 89, date_submitted: DateTime.now, iteration: @project.assignment.iterations.first)
      expect(@project_evaluation.valid?).to be_truthy
    end

    before :each do
      @points_board = PointsAward::PointsBoard.new(@student, @project_evaluation, @project.id)

      @points_board.add :project_evaluation, { points: 10, reason_id: 1 }
      @points_board.add :project_evaluation, { points: 20, reason_id: 2 }
      @points_board.add :project_evaluation, { points: 30, reason_id: 3 }
      expect(@points_board[:project_evaluation].length).to eq 3
      @persister = PointsAward::Persisters::DefaultPersister.new @points_board
    end

    # it '#call creates records in the correct table in the database' do
    #   @points_board = PointsBoard.new(student, )
    # end
    it '#call returns PointsBoard with persisted? true and no errors if successful save' do
      board = @persister.call
      expect(board.persisted?).to be_truthy
      expect(board.errors?).to be_falsy
    end

    it '#call creates new ProjectEvaluationPoints in database' do
      expect {
        @board = @persister.call
      }.to change { ProjectEvaluationPoint.count }.by 3

      expect(@board.persisted?).to be_truthy
      expect(@board.errors?).to be_falsy
    end

    it '#call records saved match the hashes in the points array' do
      @persister.call
      expect(ProjectEvaluationPoint.first.points).to eq 10
      expect(ProjectEvaluationPoint.first.reason_id).to eq 1
      expect(ProjectEvaluationPoint.second.points).to eq 20
      expect(ProjectEvaluationPoint.second.reason_id).to eq 2
      expect(ProjectEvaluationPoint.third.points).to eq 30
      expect(ProjectEvaluationPoint.third.reason_id).to eq 3
    end
  end

  describe 'LogPoint' do
    before :each do
      @student = create :student_confirmed
      @project = create :project
      sp = create :students_project, project_id: @project.id, student_id: @student.id
      @log = Log.new valid_log_entry, sp
      @points_board = PointsAward::PointsBoard.new(@student, @log)

      @points_board.add :log, { points: 10, reason_id: 1 }
      @points_board.add :log, { points: 20, reason_id: 2 }
      @points_board.add :log, { points: 30, reason_id: 3 }
      expect(@points_board[:log].length).to eq 3
      @persister = PointsAward::Persisters::DefaultPersister.new @points_board
    end

    # it '#call creates records in the correct table in the database' do
    #   @points_board = PointsBoard.new(student, )
    # end
    it '#call returns PointsBoard with persisted? true and no errors if successful save' do
      board = @persister.call
      expect(board.persisted?).to be_truthy
      expect(board.errors?).to be_falsy
    end

    it '#call creates new LogPOints in database' do
      expect {
        @board = @persister.call
      }.to change { LogPoint.count }.by 3

      expect(@board.persisted?).to be_truthy
      expect(@board.errors?).to be_falsy
    end

    it '#call records saved match the hashes in the points array' do
      @persister.call
      expect(LogPoint.first.points).to eq 10
      expect(LogPoint.first.reason_id).to eq 1
      expect(LogPoint.second.points).to eq 20
      expect(LogPoint.second.reason_id).to eq 2
      expect(LogPoint.third.points).to eq 30
      expect(LogPoint.third.reason_id).to eq 3
    end
  end
end

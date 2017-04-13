require 'rails_helper'

RSpec.describe PointsAward::Persisters::DefaultPersister, type: :model do

  it 'returns points_board object' do
    points_board = @persister.call
    expect(points_board).to be_a PointsAward::PointsBoard
  end

  describe 'PeerAssessmentPoint' do
    before :each do
      @student = instance_double "Student", id: 5
      @peer_assessment = instance_double "PeerAssessment", id: 9
      @points_board = PointsAward::PointsBoard.new(@student, @peer_assessment)

      @points_board.add :peer_assessment, { points: 10, reason: 1 }
      @points_board.add :peer_assessment, { points: 20, reason: 2 }
      @points_board.add :peer_assessment, { points: 30, reason: 3 }
      expect(@points_board[:peer_assessment].length).to eq 3
      @persister = PointsAward::Persisters::DefaultPersister.new @points_board
    end

    # it '#call creates records in the correct table in the database' do
    #   @points_board = PointsBoard.new(student, )
    # end
    it '#call returns PointsBoard with persisted? true and no errors if successful save' do
      @persister.call
      expect(@persister.persisted?).to be_truthy
      expect(@persister.errors?).to be_falsy
    end

    it '#call creates new PeerAssessmentPoints in database' do
      expect {
        @persister.call
      }.to change { PeerAssessmentPoint.count }.by 3
    end

    it '#call records saved match the hashes in the points array' do
      @persister.call
      expect(PeerAssessmentPoint.first.points).to eq 10
      expect(PeerAssessmentPoint.first.reason).to eq 1
      expect(PeerAssessmentPoint.first.points).to eq 20
      expect(PeerAssessmentPoint.first.reason).to eq 2
      expect(PeerAssessmentPoint.first.points).to eq 30
      expect(PeerAssessmentPoint.first.reason).to eq 3
    end
  end

  describe 'ProjectEvaluationPoint' do
    before :each do
      @student = instance_double "Student", id: 5
      @project_evaluation = instance_double "ProjectEvaluation", id: 9
      @points_board = PointsAward::PointsBoard.new(@student, @project_evaluation)

      @points_board.add :project_evaluation, { points: 10, reason: 1 }
      @points_board.add :project_evaluation, { points: 20, reason: 2 }
      @points_board.add :project_evaluation, { points: 30, reason: 3 }
      expect(@points_board[:project_evaluation].length).to eq 3
      @persister = PointsAward::Persisters::DefaultPersister.new @points_board
    end

    # it '#call creates records in the correct table in the database' do
    #   @points_board = PointsBoard.new(student, )
    # end
    it '#call returns PointsBoard with persisted? true and no errors if successful save' do
      @persister.call
      expect(@persister.persisted?).to be_truthy
      expect(@persister.errors?).to be_falsy
    end

    it '#call creates new PeerAssessmentPoints in database' do
      expect {
        @persister.call
      }.to change { ProjectEvaluationPoint.count }.by 3
    end

    it '#call records saved match the hashes in the points array' do
      @persister.call
      expect(ProjectEvaluationPoint.first.points).to eq 10
      expect(ProjectEvaluationPoint.first.reason).to eq 1
      expect(ProjectEvaluationPoint.first.points).to eq 20
      expect(ProjectEvaluationPoint.first.reason).to eq 2
      expect(ProjectEvaluationPoint.first.points).to eq 30
      expect(ProjectEvaluationPoint.first.reason).to eq 3
    end
  end

  describe 'LogPoint' do
    before :each do
      @student = instance_double "Student", id: 5
      @log = instance_double "Log", id: 9
      @points_board = PointsAward::PointsBoard.new(@student, @log)

      @points_board.add :log, { points: 10, reason: 1 }
      @points_board.add :log, { points: 20, reason: 2 }
      @points_board.add :log, { points: 30, reason: 3 }
      expect(@points_board[:log].length).to eq 3
      @persister = PointsAward::Persisters::DefaultPersister.new @points_board
    end

    # it '#call creates records in the correct table in the database' do
    #   @points_board = PointsBoard.new(student, )
    # end
    it '#call returns PointsBoard with persisted? true and no errors if successful save' do
      @persister.call
      expect(@persister.persisted?).to be_truthy
      expect(@persister.errors?).to be_falsy
    end

    it '#call creates new PeerAssessmentPoints in database' do
      expect {
        @persister.call
      }.to change { LogPoint.count }.by 3
    end

    it '#call records saved match the hashes in the points array' do
      @persister.call
      expect(LogPoint.first.points).to eq 10
      expect(LogPoint.first.reason).to eq 1
      expect(LogPoint.first.points).to eq 20
      expect(LogPoint.first.reason).to eq 2
      expect(LogPoint.first.points).to eq 30
      expect(LogPoint.first.reason).to eq 3
    end
  end
end

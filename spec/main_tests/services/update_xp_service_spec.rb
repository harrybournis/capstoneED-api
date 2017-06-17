require 'rails_helper'

RSpec.describe UpdateXpService, type: :model do
  Struct.new "PeerAssessment", :id

  before :each do
    @student = create :student_confirmed
    @student_profile = create :student_profile, student: @student, total_xp: 0, level: 1
    @points_board = PointsAward::PointsBoard.new(@student, Struct::PeerAssessment.new(6))
    @points_board.add(:key, { points: 20, reason_id: 6, resource_id: 1 })
    @points_board.add(:key, { points: 40, reason_id: 6, resource_id: 1 })
  end

  it 'adds as much xp as the points in the pointsboard' do
    expect {
      UpdateXpService.new(@points_board).call
    }.to change { @student.total_xp }.by 60
  end

  it 'returns the pointsboard with the xp saved under the :xp key' do
    pointsboard = UpdateXpService.new(@points_board).call

    expect(pointsboard.xp).to eq pointsboard.total_points
  end
end

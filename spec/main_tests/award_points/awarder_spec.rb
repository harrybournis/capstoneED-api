require 'rails_helper'

RSpec.describe PointsAward::Awarder, type: :model do

  it '#call creates records in the correct table in the database' do
    student = create :student
    records = [{ points: 10, reason: 2, resource_id: 1 },
               { points: 20, reason: 6, resource_id: 1 },
               { points: 50, reason: 9, resource_id: 1 }
              ]
    @points_board = PointsBoard.new(student, )
  end
  it '#call returns PointsBoard with persisted? true and no errors if successful save'
  it '#call returns PointsBoard with persisted? true and no errors if no records to save'
  it '#call returns PointsBoard with persisted? false and errors if failed to save'
end

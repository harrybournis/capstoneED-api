require 'rails_helper'

RSpec.describe PointsAward::PointsBoard, type: :model do
	PointsBoard = PointsAward::PointsBoard
  Struct.new "PeerAssessment", :id

  describe '#points' do
    before :each do

	  	@points_board = PointsBoard.new(create(:student), Struct::PeerAssessment.new(6))
    end

    it 'responds to #points' do
    	expect(@points_board).to respond_to :points
    end

    it '#points returns an hash' do
    	expect(@points_board.points).to be_kind_of Hash
    end

    it '[] gets sent to the points hash' do
      p  = @points_board.points
      expect(p).to receive(:[]).with(2)

      @points_board[2]
    end

    it 'points? returns false if empty ponts hash' do
      expect(@points_board.points).to be_empty
      expect(@points_board.points?).to be_falsy
    end
  end

  describe '#add' do
    before :each do
      @points_board = PointsBoard.new(create(:student), Struct::PeerAssessment.new(6))
    end

    it 'adds provided hash in the points hash under the provided key and creates an array if it does not already exist' do
      expect(@points_board.add(:key, { points: 20, reason_id: 6, resource_id: 1 })).to be_truthy
      expect(@points_board[:key]).to be_truthy
      expect(@points_board[:key].length).to eq 1
      expect(@points_board[:key].last[:points]).to eq 20
      expect(@points_board[:key].last[:reason_id]).to eq 6
      expect(@points_board[:key].last[:resource_id]).to eq 1
    end

    it 'adds provided hash and keeps the previous ones if key already exists' do
      @points_board.add(:key, { points: 20, reason_id: 6, resource_id: 1 })
      expect(@points_board.add(:key, { points: 40, reason_id: 3, resource_id: 4 })).to be_truthy

      expect(@points_board[:key]).to be_truthy
      expect(@points_board[:key].length).to eq 2
      expect(@points_board[:key].last[:points]).to eq 40
      expect(@points_board[:key].last[:reason_id]).to eq 3
      expect(@points_board[:key].last[:resource_id]).to eq 4
    end

    it 'raises an error if the key is not a symbol' do
      expect { @points_board.add("key", { points: 20, reason_id: 6, resource_id: 1 })
      }.to raise_error ArgumentError
    end

    it 'raises an error if the hash is missing points' do
      expect { @points_board.add(:key, { reason_id: 6, resource_id: 1 })
      }.to raise_error ArgumentError, 'Invalid hash fields.'
    end

    it 'ignores irrelevant params' do
      expect { @points_board.add(:key, { points: 20, reason_id: 6, resource_id: 1, wrong: "33" })
      }.to_not raise_error #ArguementError, 'Invalid hash fields.'
      expect(@points_board[:key].last.keys).to_not include :wrong
    end

    it 'does not raise an error if resource_id is missing' do
      expect { @points_board.add(:key, { points: 20, reason_id: 6 })
      }.to_not raise_error
    end
  end

  describe '#persisted!' do
    before :each do
      @points_board = PointsBoard.new(create(:student), Struct::PeerAssessment.new(6))
    end

    it 'responds to #persisted? and persisted!' do
      expect(@points_board).to respond_to :persisted?
    	expect(@points_board).to respond_to :persisted!
    end

    it 'turns persisted true' do
    	expect(@points_board.persisted?).to be_falsy
      @points_board.persisted!
      expect(@points_board.persisted?).to be_truthy
    end

    it 'can not persisted back to false after it has been set to true' do
      @points_board.persisted!
      expect(@points_board.persisted?).to be_truthy
      @points_board.persisted!
      expect(@points_board.persisted?).to be_truthy
    end
  end

  describe '#errors' do
    before :each do
      @points_board = PointsBoard.new(create(:student), Struct::PeerAssessment.new(6))
    end

    it 'are empty if persisted is true' do
      @points_board.persisted!
      expect(@points_board.persisted?).to be_truthy
      expect(@points_board.errors?).to be_falsy
    end

    it 'responds to errors' do
      expect(@points_board).to respond_to :errors
    end

    it 'responds to errors?' do
      expect(@points_board).to respond_to :errors?
    end
  end

  describe '#total_points' do
    before :each do
    	@points1 = 10
    	@points2 = 20
    	@points3 = 50
    	@points_board = PointsBoard.new(create(:student))
      @points_board.add :peer_assessment, { points: @points1, reason_id: 2, resource_id: 1 }
      @points_board.add :peer_assessment, { points: @points2, reason_id: 6, resource_id: 1 }
      @points_board.add :peer_assessment, { points: @points3, reason_id: 9, resource_id: 1 }
      @points_board.add :other, { points: @points1, reason_id: 2, resource_id: 1 }
      @points_board.add :other, { points: @points2, reason_id: 6, resource_id: 1 }
      @points_board.add :other, { points: @points3, reason_id: 9, resource_id: 1 }
    end

    it 'responds to #total_points' do
    	expect(@points_board).to respond_to :total_points
    end

    it 'returns the sum of all points in the array' do
    	expect(@points_board.total_points).to eq (@points1 + @points2 + @points3) * 2
    end

    it 'returns the sum of only the points in the :peer_assessment key if provided' do
      expect(@points_board.total_points(:peer_assessment)).to eq @points1 + @points2 + @points3
    end

    it 'raises error if key does not exist in the points hash' do
      expect { @points_board.total_points(:invalid_key) }.to raise_error ArgumentError
    end
  end
end

require 'rails_helper'

RSpec.describe PointsAwardService, type: :model do

  describe 'methods' do
    it '.keys returns all the keys' do
    	expect(PointsAwardService.keys).to include :peer_assessment
    end

    it '.awarders_for_key returns the awarders registered for that key' do
      expect(PointsAwardService.awarders_for_key(:peer_assessment)).to eq 'PeerAssessmentAwarder'
    end

    it '.persisters_for_key returns the persisters registered for that key' do
  		expect(PointsAwardService.persisters_for_key(:peer_assessment)).to eq 'DefaultPersister'
    end

    it '#key_exists? checks if key is defined' do
    	expect(PointsAwardService.key_exists?(:peer_assessment)).to be_truthy
    	expect(PointsAwardService.key_exists?(:wrong_key)).to be_falsy
    end

    it '#awarders and #persister are arrays with classes' do
    	s = PointsAwardService.new(:log, create(:student_confirmed))
    	expect(s.awarders).to be_kind_of Array
    	expect(s.persisters).to be_kind_of Array
    	expect(s.awarders[0]).to be_kind_of Class
    	expect(s.persisters[0]).to be_kind_of Class
    end
  end

  describe 'initialize' do

    it 'throws exception if key does not exist' do
      expect { PointsAwardService.new(:wrong_key, create(:student_confirmed))
        }.to raise_error ArgumentError
    end

    it 'call' do
      service = PointsAwardService.new(:peer_assessment, create(:student_confirmed))
      service.call
    end
  end
end

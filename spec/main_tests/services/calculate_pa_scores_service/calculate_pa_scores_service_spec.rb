require 'rails_helper'

RSpec.describe CalculatePaScoresService, type: :model do

  it 'initialize sets the default marking algorithm if not defined' do
    iteration = create :iteration
    create :game_setting, assignment: iteration.assignment, marking_algorithm_id: 666

    service = CalculatePaScoresService.new iteration
    expect(service.marking_klass).to eq Marking::Algorithms::WebPaMarkingAlgorithm
  end

  context "before iteration's deadline" do
    before :each do
      @iteration = build :iteration, start_date: DateTime.now, deadline: DateTime.now + 1.year
      @iteration.save validate: false
      create :game_setting, assignment: @iteration.assignment
      @service = CalculatePaScoresService.new(@iteration)
    end

    describe '#call' do
      it 'returns nil if iteration is not finished' do
        expect(@service.call).to be_falsy
      end

      it 'returns nil if there was an error in saving'
    end

    it '#can_mark? returns false' do
      expect(@service.can_mark?).to be_falsy
    end
  end

  context "after iteration's deadline" do
    before :each do
      @iteration = build :iteration, start_date: DateTime.now - 2.days, deadline: DateTime.now - 1.day
      @iteration.save validate: false
      create :game_setting, assignment: @iteration.assignment
      @service = CalculatePaScoresService.new(@iteration)
    end

    describe '#call' do
      it 'returns true if marks saved successfully'
      it 'changes the marks of students'
    end

    it '#can_mark? returns true if not marked before' do
      expect(@service.can_mark?).to be_truthy
    end

    it '#can_mark? returns false if marked before'
  end
end

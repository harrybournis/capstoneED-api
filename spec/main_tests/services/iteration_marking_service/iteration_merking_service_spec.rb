require 'rails_helper'

RSpec.describe IterationMarkingService, type: :model do
  before :each do
  end

  context "before iteration's deadline" do
    describe '#call' do
      it 'returns nil if iteration is not finished'
      it 'returns nil if there was an error in saving'
      it 'returns nil if there was an error in saving'
    end

    it '#can_mark? returns false'
  end

  context "after iteration's deadline" do
    describe '#call' do
      it 'returns true if marks saved successfully'
      it 'changes the marks of students'
    end

    it '#can_mark? returns true'
  end
end

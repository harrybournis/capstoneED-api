require 'rails_helper'

RSpec.describe Marking::Results, type: :model do
  before :each do
    @student_id1 = 1
    @student_id2 = 2
    @score1 = 0.83
    @score2 = 1.13
    @mark1 = 60
    @mark2 = 58
    @results = Marking::Results.new
  end

  it '#add_score adds the score for the student_id' do
    expect(@results.score(@student_id1)).to be_falsy
    expect(@results.add_score(@student_id1, @score1)).to be_truthy
    expect(@results.score(@student_id1)).to eq @score1
  end

  it '#add_score returns nil if student already has a score' do
    expect(@results.add_score(@student_id1, @score1)).to be_truthy
    expect(@results.add_score(@student_id1, @score1)).to be_falsy
  end

  it '#add_mark adds the mark for the student_id' do
    expect(@results.mark(@student_id1)).to be_falsy
    expect(@results.add_mark(@student_id1, @mark1)).to be_truthy
    expect(@results.mark(@student_id1)).to eq @mark1
  end

  it '#add_mark returns nil if student already has a mark' do
    expect(@results.add_mark(@student_id1, @mark1)).to be_truthy
    expect(@results.add_mark(@student_id1, @mark1)).to be_falsy
  end

  it '#marked? returns false if no marks are set' do
    expect(@results.marked?).to be_falsy
    @results.add_mark(@student_id1, @mark1)
    expect(@results.marked?).to be_truthy
  end

  it '#score(student_id) returns the score for the student_id' do
    @results.add_score(@student_id1, @score1)
    expect(@results.score(@student_id1)).to eq @score1
  end

  it '#score(student_id) returns nil if student_id does not exist' do
    expect(@results.score(@student_id1)).to be_falsy
  end

  it '#mark(student_id) returns nil if student_id does not exist' do
    expect(@results.mark(@student_id1)).to be_falsy
  end
  it '#mark(student_id) returns the mark for the student_id' do
    @results.add_mark(@student_id1, @mark1)
    expect(@results.mark(@student_id1)).to eq @mark1
  end
end


require 'rails_helper'

RSpec.describe MarkingAlgorithms::Results, type: :model do
  context 'contains scores' do
    it 'marked? returns false'
    @results.score(student_id)
    @results.mark(student_id)
  end

  context 'contains marks' do
    it 'marked? returns false'
  end
end


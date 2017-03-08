require 'rails_helper'

RSpec.describe QuestionType, type: :model do

  it 'works' do
    q = QuestionType.new category: 'text', friendly_name: 'textaki'
    expect(q.save).to be_truthy
  end

  it 'factory works' do
    expect(create(:question_type)).to be_truthy
  end
end

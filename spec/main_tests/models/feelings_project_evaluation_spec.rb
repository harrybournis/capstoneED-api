require 'rails_helper'

RSpec.describe FeelingsProjectEvaluation, type: :model do
  it 'works' do
    expect(create(:feelings_project_evaluation)).to be_truthy
  end

  it { should belong_to :feeling }
  it { should belong_to :project_evaluation }
  it { should validate_presence_of :feeling }
  it { should validate_presence_of :project_evaluation }
  it { should validate_presence_of :percent }
  it { should validate_numericality_of(:percent).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
end

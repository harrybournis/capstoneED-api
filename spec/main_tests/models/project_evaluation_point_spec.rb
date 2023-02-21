require 'rails_helper'

RSpec.describe ProjectEvaluationPoint, type: :model do
  subject(:project_evaluation_point) { build :project_evaluation_point }

  it { should belong_to :project }
  it { should belong_to :project_evaluation }
  it { should belong_to :student }

  it { should validate_presence_of :points }
  it { should validate_presence_of :date }
  it { should validate_presence_of :project_id }
  it { should validate_presence_of :project_evaluation_id }
  it { should validate_presence_of :student_id }
  it { should validate_presence_of :reason_id }

  it 'works' do
    expect(FactoryBot.create(:project_evaluation_point)).to be_truthy
  end
end

require 'rails_helper'

RSpec.describe PeerAssessmentPoint, type: :model do
  subject(:peer_assessment_point) { build :peer_assessment_point }

  it { should belong_to :project }
  it { should belong_to :peer_assessment }
  it { should belong_to :student }

  it { should validate_presence_of :points }
  it { should validate_presence_of :date }
  it { should validate_presence_of :project_id }
  it { should validate_presence_of :peer_assessment_id }
  it { should validate_presence_of :student_id }
  it { should validate_presence_of :reason_id }

  it 'works' do
    expect(FactoryBot.create(:peer_assessment_point)).to be_truthy
  end
end

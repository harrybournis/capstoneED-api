require 'rails_helper'

RSpec.describe IterationMark, type: :model do

  it 'works' do
    expect(create(:iteration_mark)).to be_truthy
    expect(create(:iteration_mark_score_only)).to be_truthy
    expect(create(:iteration_mark_marked)).to be_truthy
  end

  subject(:iteration_mark) { FactoryBot.build(:iteration_mark) }

  it { should validate_presence_of :student_id }
  it { should validate_presence_of :iteration_id }
  it { should validate_numericality_of(:mark).only_integer
                                             .allow_nil
                                             .is_greater_than_or_equal_to(0)
                                             .is_less_than_or_equal_to(100)
                                             .with_message('must be between 0 and 100') }

  it { should belong_to :student }
  it { should belong_to :iteration }

  it 'marked? returns false if mark is not set' do
    expect(create(:iteration_mark).marked?).to be_falsy
    expect(create(:iteration_mark_score_only).marked?).to be_falsy
    expect(create(:iteration_mark_marked).marked?).to be_truthy
  end
end

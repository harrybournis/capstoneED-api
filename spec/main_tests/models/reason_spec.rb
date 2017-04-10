require 'rails_helper'

RSpec.describe Reason, type: :model do
  subject(:reason) { build :reason }

  it { should validate_presence_of :value }
  it { should have_many :log_points }

  it 'validates uniqueness of value' do
    reason1 = Reason.new value: 0
    reason1.save
    expect(reason1.errors).to be_empty

    reason2 = Reason.new value: 1
    reason2.save
    expect(reason2.errors).to be_empty

    reason3 = Reason.new value: 0
    reason3.save
    expect(reason3.errors).to_not be_empty
  end
end

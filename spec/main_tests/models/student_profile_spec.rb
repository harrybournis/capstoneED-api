require 'rails_helper'

RSpec.describe StudentProfile, type: :model do

  it 'works' do
    expect(FactoryGirl.create(:student_profile)).to be_truthy
  end

  it { should belong_to :student }

  it { should validate_presence_of :total_xp }
  it { should validate_presence_of :level }
end

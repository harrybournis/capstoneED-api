require 'rails_helper'

RSpec.describe StudentProfile, type: :model do

  it 'works' do
    expect(FactoryBot.create(:student_profile)).to be_truthy
  end

  it { should belong_to :student }

  it { should validate_presence_of :total_xp }
  it { should validate_presence_of :level }

  before :all do
    @sp = create :student_profile, total_xp: 200
    @coefficient = 0.02
  end

  it '#calculate_level calculates the current level based on their total_xp' do
    expect(@sp.level).to eq 1

    expect(@sp.calculate_level(@coefficient)).to eq 2
    expect(@sp.level).to eq 2
  end

  it '#calculate_level returns 1 if there is 0 total_xp' do
    @sp.total_xp = 0

    expect(@sp.calculate_level(@coefficient)).to eq 1
  end

  it '#calculate_level returns 1 if level is less than 1' do
    @sp.total_xp = 10

    expect(@sp.calculate_level(@coefficient)).to eq 1
  end

  it '#calculate_level returns 7 if the result is bigger than 7' do
    @sp.total_xp = 10000000

    expect(@sp.calculate_level(@coefficient)).to eq 7
  end

  it '#calculate_xp_to_next_level returns the maimaining xp to reach the next level' do
    @sp.total_xp = 190

    expect(@sp.calculate_level(@coefficient)).to eq 1
    expect(@sp.calculate_xp_to_next_level(@coefficient)).to eq 10
  end
end

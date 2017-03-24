require 'rails_helper'

RSpec.describe GameSetting, type: :model do

  it 'works' do
    expect(create :game_setting).to be_truthy
  end

  it { should belong_to :assignment }

  it "saves with the default settings if no parameters provided" do
    assignment = create :assignment
    setting = GameSetting.new assignment_id: assignment.id

    expect(setting.save).to be_truthy
  end

  it "keeps the parameters provided" do
    assignment = create :assignment
    setting = GameSetting.new assignment_id: assignment.id, points_log: 14

    expect(setting.save).to be_truthy
    expect(setting.points_log).to eq 14
  end

  it 'is invalid if one parameter is not an integer' do
    assignment = create :assignment
    setting = GameSetting.new assignment_id: assignment.id, points_log: 'wrong string'

    expect(setting.save).to be_falsy
    expect(setting.errors[:points_log][0]).to include 'not a number'
  end

end

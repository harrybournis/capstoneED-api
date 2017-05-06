require 'spec_helper'
require 'rails_helper'

RSpec.describe 'Whenever Schedule' do
  it 'makes sure runner statement exists' do
    schedule = Whenever::Test::Schedule.new(file: 'config/schedule.rb')

    expect(schedule.jobs[:runner].count).to eq 1

    schedule.jobs[:runner].each { |job| instance_eval job[:task] }
  end

  it 'executes PaScoreJob every day at 12am' do
    schedule = Whenever::Test::Schedule.new(file: 'config/schedule.rb')

    expect(schedule.jobs[:runner][0][:every][0]).to eq 1.day.to_i
    expect(schedule.jobs[:runner][0][:every][1][:at]).to eq '12am'
  end
end


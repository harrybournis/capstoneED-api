require 'rails_helper'

RSpec.describe Reason, type: :model do

  it '#key_from_id returns the key' do
    expect(Reason.key_from_id(1)).to eq :peer_assessment
    expect(Reason.key_from_id(2)).to eq :project_evaluation
  end

  it 'contains :peer_assessment' do
    expect(Reason[:peer_assessment]).to be_truthy
    expect(Reason[:peer_assessment][:id]).to eq 1
  end

  it 'contains :project_evaluation' do
    expect(Reason[:project_evaluation]).to be_truthy
    expect(Reason[:project_evaluation][:id]).to eq 2
  end

  it 'contains :log_first_of_day' do
    expect(Reason[:log_first_of_day]).to be_truthy
    expect(Reason[:log_first_of_day][:id]).to eq 3
  end

  it 'contains :peer_assessment_first_of_team' do
    expect(Reason[:peer_assessment_first_of_team]).to be_truthy
    expect(Reason[:peer_assessment_first_of_team][:id]).to eq 4
  end

  it 'contains :project_evaluation_first_of_team' do
    expect(Reason[:project_evaluation_first_of_team]).to be_truthy
    expect(Reason[:project_evaluation_first_of_team][:id]).to eq 5
  end

  it 'contains :log_first_of_team' do
    expect(Reason[:log_first_of_team]).to be_truthy
    expect(Reason[:log_first_of_team][:id]).to eq 6
  end

  it 'contains :peer_assessment_first_of_assignment' do
    expect(Reason[:peer_assessment_first_of_assignment]).to be_truthy
    expect(Reason[:peer_assessment_first_of_assignment][:id]).to eq 7
  end

  it 'contains :project_evaluation_first_of_assignment' do
    expect(Reason[:project_evaluation_first_of_assignment]).to be_truthy
    expect(Reason[:project_evaluation_first_of_assignment][:id]).to eq 8
  end

  it 'contains :log_first_of_assignment' do
    expect(Reason[:log_first_of_assignment]).to be_truthy
    expect(Reason[:log_first_of_assignment][:id]).to eq 9
  end

end

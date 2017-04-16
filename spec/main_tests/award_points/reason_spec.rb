require 'rails_helper'

RSpec.describe Reason, type: :model do

  it '#key_from_id returns the key' do
    expect(Reason.key_from_id(1)).to eq :peer_assessment
    expect(Reason.key_from_id(2)).to eq :project_evaluation
  end

  it 'contains :peer_assessment' do
    expect(Reason[:peer_assessment]).to be_truthy
  end

  it 'contains :project_evaluation' do
    expect(Reason[:project_evaluation]).to be_truthy
  end

  it 'contains :log_first_of_day' do
    expect(Reason[:log_first_of_day]).to be_truthy
  end

  it 'contains :peer_assessment_first_of_team' do
    expect(Reason[:peer_assessment_first_of_team]).to be_truthy
  end

  it 'contains :project_evaluation_first_of_team' do
    expect(Reason[:project_evaluation_first_of_team]).to be_truthy
  end

  it 'contains :log_first_of_team' do
    expect(Reason[:log_first_of_team]).to be_truthy
  end

  it 'contains :peer_assessment_first_of_assignment' do
    expect(Reason[:peer_assessment_first_of_assignment]).to be_truthy
  end

  it 'contains :project_evaluation_first_of_assignment' do
    expect(Reason[:project_evaluation_first_of_assignment]).to be_truthy
  end

  it 'contains :log_first_of_assignment' do
    expect(Reason[:log_first_of_assignment]).to be_truthy
  end

end

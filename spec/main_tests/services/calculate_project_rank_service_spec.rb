require 'rails_helper'

RSpec.describe CalculateProjectRankService, type: :model do
  before :each do
    @assignment = create :assignment
    @project1 = create :project, assignment: @assignment
    @project2 = create :project, assignment: @assignment
    @project3 = create :project, assignment: @assignment

    create :students_project, project: @project1,  points: 10
    create :students_project, project: @project1, points: 0
    create :students_project, project: @project2,  points: 10
    create :students_project, project: @project2, points: 5
    create :students_project, project: @project2, points: 5
    create :students_project, project: @project3,  points: 20
    create :students_project, project: @project3, points: 10

    expect(@project1.team_points).to eq 10
    expect(@project2.team_points).to eq 20
    expect(@project3.team_points).to eq 30
  end

  it 'returns the correct rank' do
    service = CalculateProjectRankService.new @assignment

    result = service.call

    expect(result).to be_truthy
    expect(result[@project1.id]).to eq 3
    expect(result[@project2.id]).to eq 2
    expect(result[@project3.id]).to eq 1
  end

  it 'gives the same rank number to project with the same points' do
    create :students_project, project: @project2, points: 10
    @project2 = Project.find(@project2.id)
    expect(@project2.team_points).to eq 30

    service = CalculateProjectRankService.new @assignment
    result = service.call

    expect(result[@project1.id]).to eq 3
    expect(result[@project2.id]).to eq 1
    expect(result[@project3.id]).to eq 1
  end
  it '#update! updates a projects rank in the database' do
    service = CalculateProjectRankService.new @assignment
    result = service.call

    expect {
      service.update!
    }.to change  { Project.find(@project1.id).rank }

    @project1.reload
    @project2.reload
    @project3.reload
    expect(@project1.rank).to eq 3
    expect(@project2.rank).to eq 2
    expect(@project3.rank).to eq 1
  end
end

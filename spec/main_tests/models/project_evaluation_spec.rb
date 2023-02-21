require 'rails_helper'
require 'timecop'

RSpec.describe ProjectEvaluation, type: :model do

  it { should belong_to :user }
  it { should belong_to :project }
  it { should belong_to :iteration }
  it { should have_many :feelings_project_evaluations }
  it { should have_many(:feelings).through(:feelings_project_evaluations)}

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :project_id }
  it { should validate_presence_of :iteration_id }
  it { should validate_presence_of :percent_complete }
  it { should validate_presence_of :feelings_average }

  it 'works' do
    expect(create(:project_evaluation)).to be_truthy
  end

  it 'FactoryBot creates iteration that has the same assignment as the project' do
    pe = create(:project_evaluation)
    expect(pe.iteration.assignment).to eq(pe.project.assignment)
  end

  it 'validates that iteration belongs to the project Success' do
    assignment = create(:assignment)
    project = create(:project, assignment: assignment)
    iteration = create(:iteration, assignment: assignment)
    #pe.project.students << pe.user
    pe = build(:project_evaluation, iteration_id: iteration.id)
    pe.project = project
    create :students_project, student: pe.user, project: pe.project

    Timecop.travel iteration.start_date + 2.hours do
      expect(pe.save).to be_truthy
    end
  end

  it 'validates that iteration belongs to the project Error' do
    assignment = create(:assignment)
    project = create(:project)
    iteration = create(:iteration, assignment: assignment )

    pe = build(:project_evaluation)
    pe.project = project
    pe.iteration = iteration

    expect(pe.save).to be_falsy
    expect(pe.errors[:iteration_id][0]).to include('does not belong')
  end

  it 'validates that iteration is active Error' do
    now = DateTime.now
    assignment = create(:assignment)
    project = create(:project, assignment: assignment)
    iteration = create(:iteration, assignment: assignment)

    Timecop.travel iteration.deadline + 1.hour do
      pe = build(:project_evaluation)
      pe.project = project
      pe.iteration = iteration

      expect(pe.save).to be_falsy
      expect(pe.errors[:iteration_id][0]).to include("no later")
    end
  end

  it 'validates that iteration is active Success' do
    now = DateTime.now
    assignment = create(:assignment)
    project = create(:project, assignment: assignment)
    iteration = create(:iteration, assignment: assignment)

    Timecop.travel iteration.start_date + 5.hours do
      pe = build(:project_evaluation)
      pe.project = project
      #pe.project.students << pe.user
      create :students_project, student: pe.user, project: pe.project
      pe.iteration = iteration

      expect(pe.save).to be_truthy
    end
  end

  it 'validates that it is within the limit of project evaluations for a single iteration for a single user Error' do
    LIMITError = 2
    now = DateTime.now

    user = create(:lecturer)
    user.units << create(:unit)
    assignment = create(:assignment, lecturer: user, unit: user.units[0])
    project = create(:project, assignment: assignment, lecturer: user)
    iteration = create(:iteration, assignment: assignment)


    Timecop.travel iteration.start_date + 1.hour do
      pe = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feelings_average: 32)
      expect(pe.save).to be_truthy
      pe2 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feelings_average: 32)
      expect(pe2.save).to be_truthy

      pe3 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feelings_average: 32)

      expect(pe3.save).to be_falsy
      expect(pe3.errors[:iteration_id][0]).to include('limit')
    end
  end

  it 'validates that it is within the limit of project evaluations for a single iteration for a single user accounting for Lecturer' do
    LIMITLecturer = 2
    now = DateTime.now

    user = create(:lecturer)
    user.units << create(:unit)
    assignment = create(:assignment, lecturer: user, unit: user.units[0])
    project = create(:project, assignment: assignment, lecturer: user)
    iteration = create(:iteration, assignment: assignment)


    Timecop.travel iteration.start_date + 1.hour do
      pe = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feelings_average: 32)
      expect(pe.save).to be_truthy
      pe2 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feelings_average: 32)
      expect(pe2.save).to be_truthy

      different_project = create(:project, assignment: assignment, lecturer: user)
      pe3 = ProjectEvaluation.new(project_id: different_project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feelings_average: 32)

      expect(pe3.save).to be_truthy
    end
  end

  it 'validates that it is within the limit of project evaluations for a single iteration for a single user Success' do
    LIMITSuccess = 2
    now = DateTime.now

    user = create(:lecturer)
    user.units << create(:unit)
    assignment = create(:assignment, lecturer: user, unit: user.units[0])
    project = create(:project, assignment: assignment, lecturer: user)
    iteration = create(:iteration, assignment: assignment)


    Timecop.travel iteration.start_date + 1.hour do
      pe = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feelings_average: 32)
      expect(pe.save).to be_truthy
      pe2 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feelings_average: 32)
      expect(pe2.save).to be_truthy

      user = create(:student)
      #project.students << user
      create :students_project, student: user, project: project
      pe3 = ProjectEvaluation.new(project_id: project.id, iteration_id: iteration.id, percent_complete: 14, user_id: user.id, feelings_average: 32)

      expect(pe3.save).to be_truthy
    end
  end

  it 'validates that the user is associated with the project' do
    irrelevant_student = create(:student)
    pe = build(:project_evaluation)
    pe.user = irrelevant_student

    expect(pe.save).to be_falsy
    expect(pe.errors[:user_id][0]).to include("not associated")
  end

  it 'validates that percent complete is between 0 and 100' do
    pe = build(:project_evaluation, percent_complete: 101)

    expect(pe.save).to be_falsy
    expect(pe.errors[:percent_complete][0]).to include("between 0 and 100")
  end

  it 'sets the current time as date_submitted' do
    now = DateTime.now

    Timecop.freeze(now) do
      pe = create(:project_evaluation, date_submitted: nil)
      pe.save

      expect(pe.date_submitted.to_i).to eq(now.to_i)
    end
  end

  it 'does not mess up the date submitted when updating' do
    now = DateTime.now

    Timecop.freeze(now) do
      pe = create(:project_evaluation, date_submitted: nil)
      pe.save

      expect(pe.date_submitted.to_i).to eq(now.to_i)

      pe.reload
      new_date_submitted = DateTime.now + 1.day

      pe.date_submitted = new_date_submitted
      pe.save

      expect(pe.date_submitted).to eq(new_date_submitted)
    end
  end

  it 'sets the feelings_average before saving a new record' do
    pe = ProjectEvaluation.new(attributes_for(:project_evaluation).merge(feelings_project_evaluations_attributes: valid_feelings_params))

    expect(pe.save).to be_truthy
    expect(pe.feelings_average).to be_truthy
  end

  it 'calculates the average for feelings depending on if they are + or -' do
    feeling_pos = create :feeling, value: 1
    feeling_neg = create :feeling, value: -1
    expect(Feeling.count).to eq 2
    feelings_params = [{ feeling_id: feeling_pos.id, percent: 86 }, { feeling_id: feeling_neg.id, percent: 13 }]

    pe = ProjectEvaluation.new(attributes_for(:project_evaluation).merge(feelings_project_evaluations_attributes: feelings_params))
    expect(pe.save).to be_truthy
    expect(pe.feelings_average).to eq (86 - 13) / 2
  end
end

require 'rails_helper'

RSpec.describe Marking::Persisters::DatabasePersister, type: :model do
  before :each do
    @assignment = create :assignment, start_date: DateTime.now, end_date: DateTime.now + 2.days
    @project = create :project, assignment: @assignment
    @iteration = create :iteration, assignment: @assignment
    @student1 = create :student_confirmed
    @student2 = create :student_confirmed
    @student3 = create :student_confirmed
    @student4 = create :student_confirmed
    @student5 = create :student_confirmed
    create :students_project, student: @student1, project: @project
    create :students_project, student: @student2, project: @project

    @results = Marking::Results.new
    #results.add_score(@student1.id, 0.11299793956044)
    @results.add_score(@student1.id, 0.112997939560439560375e1)
    @results.add_score(@student2.id, 0.147853708791208791125e1)
    @results.add_score(@student3.id,0.111881868131868131875e1)
    @results.add_score(@student4.id,  0.85525412087912087875e0)
    @results.add_score(@student5.id, 0.41741071428571428625e0)
  end

  it 'saves the scores for each student in the database' do
    persister = Marking::Persisters::DatabasePersister.new(@iteration,@results)
    expect {
      persister.save!
    }.to change { IterationMark.count }.by 5

    expect(IterationMark.find_by(student_id: @student1.id, iteration_id: @iteration.id).pa_score.round(1)).to eq 1.1
  end

  it 'sets is_marked of the iteration to true on successful save' do
    persister = Marking::Persisters::DatabasePersister.new(@iteration,@results)
    expect {
      persister.save!
    }.to change { Iteration.find(@iteration.id).is_scored }.from(false).to(true)

    expect(IterationMark.find_by(student_id: @student1.id, iteration_id: @iteration.id).pa_score.round(1)).to eq 1.1
  end
end

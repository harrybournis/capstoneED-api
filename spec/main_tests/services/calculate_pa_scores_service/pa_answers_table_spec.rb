require 'rails_helper'

RSpec.describe Marking::PaAnswersTable, type: :model do
  def pa_questions(number_id, text_id, rank_id)
    [{ 'text' => "1st", 'type_id' => number_id },
    { 'text' => "2nd", 'type_id' => number_id },
    { 'text' => "2nd", 'type_id' => rank_id },
    { 'text' => "2nd", 'type_id' => number_id },
    { 'text' => "2nd", 'type_id' => number_id },
    { 'text' => "3rd", 'type_id' => text_id }]
  end

  def pa_answers
    [{ question_id: 1, answer: 1 }, { question_id: 2, answer: 4 },
    { question_id: 3, answer: 3 }, { question_id: 4, answer: 3 },
    { question_id: 5, answer: 5 }, { question_id: 6, answer: 'text stuff' }]
  end

  def pa_answers2
    [{ question_id: 1, answer: 2 }, { question_id: 2, answer: 3 },
    { question_id: 3, answer: 2 }, { question_id: 4, answer: 5 },
    { question_id: 5, answer: 4 }, { question_id: 6, answer: 'text stuff' }]
  end

  def pa_answers3
    [{ question_id: 1, answer: 3 }, { question_id: 2, answer: 2 },
    { question_id: 3, answer: 5 }, { question_id: 4, answer: 4 },
    { question_id: 5, answer: 3 }, { question_id: 6, answer: 'text stuff' }]
  end

  before :all do
    @q_type_text = FactoryGirl.create :question_type, category: 'text', friendly_name: 'Text'
    @q_type_number = FactoryGirl.create :question_type, category: 'number', friendly_name: 'Number'
    @q_type_rank = FactoryGirl.create :question_type, category: 'rank', friendly_name: 'Rank'
    @assignment = create :assignment
    @project = create :project, assignment: @assignment
    @game_setting = create :game_setting, assignment: @assignment
    @iteration = create :iteration, assignment: @assignment
    @pa_form = create :pa_form, iteration: @iteration, questions: pa_questions(@q_type_number.id, @q_type_text.id, @q_type_rank.id)
    @student1 = create :student_confirmed
    @student2 = create :student_confirmed
    @student3 = create :student_confirmed
    @student_did_not_submit = create :student_confirmed
    create :students_project, project: @project, student: @student1
    create :students_project, project: @project, student: @student2
    create :students_project, project: @project, student: @student3
    create :students_project, project: @project, student: @student_did_not_submit
    pas = []
    pas << (@pa11 = build :peer_assessment, submitted_by:  @student1, submitted_for: @student1, pa_form_id: @iteration.pa_form.id, answers: pa_answers, project_id: @project.id)
    pas << (@pa12 = build :peer_assessment, submitted_by:  @student1, submitted_for: @student2, pa_form_id: @iteration.pa_form.id, answers: pa_answers, project_id: @project.id)
    pas << (@pa13 = build :peer_assessment, submitted_by:  @student1, submitted_for: @student3, pa_form_id: @iteration.pa_form.id, answers: pa_answers, project_id: @project.id)
    pas << (@pa13 = build :peer_assessment, submitted_by:  @student1, submitted_for: @student_did_not_submit, pa_form_id: @iteration.pa_form.id, answers: pa_answers, project_id: @project.id)
    pas << (@pa21 = build :peer_assessment,  submitted_by:  @student2, submitted_for: @student1, pa_form_id: @iteration.pa_form.id, answers: pa_answers2, project_id: @project.id)
    pas << (@pa22 = build :peer_assessment,  submitted_by:  @student2, submitted_for: @student2, pa_form_id: @iteration.pa_form.id, answers: pa_answers2, project_id: @project.id)
    pas << (@pa23 = build :peer_assessment,  submitted_by:  @student2, submitted_for: @student3, pa_form_id: @iteration.pa_form.id, answers: pa_answers2, project_id: @project.id)
    pas << (@pa23 = build :peer_assessment,  submitted_by:  @student2, submitted_for: @student_did_not_submit, pa_form_id: @iteration.pa_form.id, answers: pa_answers2, project_id: @project.id)
    pas << (@pa31 = build :peer_assessment,  submitted_by:  @student3, submitted_for: @student1, pa_form_id: @iteration.pa_form.id, answers: pa_answers3, project_id: @project.id)
    pas << (@pa32 = build :peer_assessment,  submitted_by:  @student3, submitted_for: @student2, pa_form_id: @iteration.pa_form.id, answers: pa_answers3, project_id: @project.id)
    pas << (@pa33 = build :peer_assessment,  submitted_by:  @student3, submitted_for: @student3, pa_form_id: @iteration.pa_form.id, answers: pa_answers3, project_id: @project.id)
    pas << (@pa33 = build :peer_assessment,  submitted_by:  @student3, submitted_for: @student_did_not_submit, pa_form_id: @iteration.pa_form.id, answers: pa_answers3, project_id: @project.id)
    pas.each { |p| p.save(validate: false) }
    expect(@iteration.peer_assessments.count).to eq 12
    expect(@project.students.count).to eq 4
    @table = Marking::PaAnswersTable.new @project, @pa_form
  end

  it '#question_ids returns the ids of the questions that are not text' do
    expect(@table.question_ids.length).to eq pa_answers.length - 1
    expect(@table.question_ids).to eq [1, 2, 3, 4, 5]
  end

  # it '#student_index returns the index of the student in the table for an id' do
  #   expect(@table.student_index(@student1.id)).to eq 0
  #   expect(@table.student_index(@student2.id)).to eq 1
  #   expect(@table.student_index(@student3.id)).to eq 2
  # end

  # it '#student_index returns nil if the id is not found' do
  #   expect(@table.student_index(4743737)).to be nil
  # end

  it '#awarded_by(student_id, question_id) returns the points awarded by the a student for question_id (table row)' do
    expect(@table.awarded_by(@student1.id, 1)).to eq [1,1,1,1]
    expect(@table.awarded_by(@student2.id, 1)).to eq [2,2,2,2]
    expect(@table.awarded_by(@student3.id, 1)).to eq [3,3,3,3]
    expect(@table.awarded_by(@student_did_not_submit.id, 1)).to eq [0,0,0,0]
  end

  it '#received_by(student_id, question_id) returns the marks that student_id received from others for question_id (table column)' do
    expect(@table.received_by(@student1.id, 1)).to eq [1,2,3,0]
    expect(@table.received_by(@student2.id, 1)).to eq [1,2,3,0]
    expect(@table.received_by(@student3.id, 1)).to eq [1,2,3,0]
    expect(@table.received_by(@student1.id, 2)).to eq [4,3,2,0]
  end

  it '#by_for(awarder_id, receiver_id, question_id) returns the marks awarded by awarder_id for receiver_id for question_id (table cell)' do
    expect(@table.by_for(@student1.id, @student2.id, 1)).to eq 1
    expect(@table.by_for(@student2.id, @student1.id, 1)).to eq 2
    expect(@table.by_for(@student3.id, @student1.id, 1)).to eq 3
    expect(@table.by_for(@student3.id, @student1.id, 2)).to eq 2
    expect(@table.by_for(@student_did_not_submit.id, @student1.id, 3)).to eq 0
  end

  it '#everyone_submitted? returns true if everyone submitted' do
    pa = build :peer_assessment, submitted_by:  @student_did_not_submit, submitted_for: @student1, pa_form_id: @iteration.pa_form.id, answers: pa_answers, project_id: @project.id
    pa.save(validate: false)
    expect(@project.students.length).to eq @project.peer_assessments.group(:submitted_by_id).count.length

    table = Marking::PaAnswersTable.new @project, @pa_form
    expect(table.everyone_submitted?).to be_truthy
  end

  it '#everyone_submitted? returns false if one did not submit' do
    expect(@table.everyone_submitted?).to be_falsy
  end
end

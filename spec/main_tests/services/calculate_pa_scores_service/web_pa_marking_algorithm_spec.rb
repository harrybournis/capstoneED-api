require 'rails_helper'

RSpec.describe Marking::Algorithms::WebPaMarkingAlgorithm, type: :model do
  context '.calculate_score' do
    it 'gives the same marks as WebPA example' do
      now = DateTime.now
      @lecturer = create :lecturer_confirmed
      @unit = create :unit, lecturer: @lecturer
      @assignment = create :assignment, unit: @unit, lecturer: @lecturer, start_date: now - 1.day, end_date: now + 2.days
      @iteration = create :iteration, assignment: @assignment
      @pa_form = create :pa_form, iteration: @iteration
      @qtype = create :question_type, category: 'number'
      @pa_form.questions = [{ 'text' => 'text', 'type_id' => @qtype.id }]
      @pa_form.save
      @project = create :project, assignment: @assignment

      @alice = create :student_confirmed
      @bob = create :student_confirmed
      @claire = create :student_confirmed
      @david = create :student_confirmed
      @elaine = create :student_confirmed

      create :students_project, student: @alice, project: @project
      create :students_project, student: @bob, project: @project
      create :students_project, student: @claire, project: @project
      create :students_project, student: @david, project: @project
      create :students_project, student: @elaine, project: @project

      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @alice, answers: [{'question_id' => 1, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @bob, answers: [{'question_id' => 1, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @claire, answers: [{'question_id' => 1, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @david, answers: [{'question_id' => 1, 'answer' => 2}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @elaine, answers: [{'question_id' => 1, 'answer' => 1}]

      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @alice, answers: [{'question_id' => 1, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @bob, answers: [{'question_id' => 1, 'answer' => 5}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @claire, answers: [{'question_id' => 1, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @david, answers: [{'question_id' => 1, 'answer' => 2}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @elaine, answers: [{'question_id' => 1, 'answer' => 0}]

      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @alice, answers: [{'question_id' => 1, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @bob, answers: [{'question_id' => 1, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @claire, answers: [{'question_id' => 1, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @david, answers: [{'question_id' => 1, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @elaine, answers: [{'question_id' => 1, 'answer' => 4}]

      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @alice, answers: [{'question_id' => 1, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @bob, answers: [{'question_id' => 1, 'answer' => 5}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @claire, answers: [{'question_id' => 1, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @david, answers: [{'question_id' => 1, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @elaine, answers: [{'question_id' => 1, 'answer' => 1}]

      Timecop.travel @iteration.deadline + 1.day do
        answers_table = Marking::PaAnswersTable.new(@project, @pa_form)
        results = Marking::Algorithms::WebPaMarkingAlgorithm.calculate_scores(answers_table)
        expect(results.score(@alice.id).round(1)).to eq 1.1
        expect(results.score(@bob.id).round(1)).to eq 1.5
        expect(results.score(@claire.id).round(1)).to eq 1.1
        expect(results.score(@david.id).round(1)).to eq 0.9
        expect(results.score(@elaine.id).round(1)).to eq 0.4
      end
    end

    it 'works for multiple questions' do
      now = DateTime.now
      @lecturer = create :lecturer_confirmed
      @unit = create :unit, lecturer: @lecturer
      @assignment = create :assignment, unit: @unit, lecturer: @lecturer, start_date: now - 1.day, end_date: now + 2.days
      @iteration = create :iteration, assignment: @assignment
      @pa_form = create :pa_form, iteration: @iteration
      @qtype = create :question_type, category: 'number'
      @pa_form.questions = [{ 'text' => 'text', 'type_id' => @qtype.id }, { 'text' => 'qustion2', 'type_id' => @qtype.id} ]
      @pa_form.save
      @project = create :project, assignment: @assignment

      @alice = create :student_confirmed
      @bob = create :student_confirmed
      @claire = create :student_confirmed
      @david = create :student_confirmed
      @elaine = create :student_confirmed

      create :students_project, student: @alice, project: @project
      create :students_project, student: @bob, project: @project
      create :students_project, student: @claire, project: @project
      create :students_project, student: @david, project: @project
      create :students_project, student: @elaine, project: @project

      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @alice, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @bob, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @claire, answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @david, answers: [{'question_id' => 1, 'answer' => 2}, {'question_id' => 2, 'answer' => 2}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @alice, submitted_for: @elaine, answers: [{'question_id' => 1, 'answer' => 1}, {'question_id' => 2, 'answer' => 1}]

      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @alice, answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @bob, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @claire, answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @david, answers: [{'question_id' => 1, 'answer' => 2}, {'question_id' => 2, 'answer' => 2}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @bob, submitted_for: @elaine, answers: [{'question_id' => 1, 'answer' => 0}, {'question_id' => 2, 'answer' => 0}]

      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @alice, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @bob, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @claire, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @david, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @claire, submitted_for: @elaine, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}]

      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @alice, answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @bob, answers: [{'question_id' => 1, 'answer' => 5}, {'question_id' => 2, 'answer' => 5}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @claire, answers: [{'question_id' => 1, 'answer' => 4}, {'question_id' => 2, 'answer' => 4}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @david, answers: [{'question_id' => 1, 'answer' => 3}, {'question_id' => 2, 'answer' => 3}]
      create :peer_assessment, pa_form: @pa_form, submitted_by: @david, submitted_for: @elaine, answers: [{'question_id' => 1, 'answer' => 1}, {'question_id' => 2, 'answer' => 1}]

      Timecop.travel @iteration.deadline + 1.day do
        answers_table = Marking::PaAnswersTable.new(@project, @pa_form)
        results = Marking::Algorithms::WebPaMarkingAlgorithm.calculate_scores(answers_table)

        expect(results.score(@alice.id).round(1)).to eq 1.1
        expect(results.score(@bob.id).round(1)).to eq 1.5
        expect(results.score(@claire.id).round(1)).to eq 1.1
        expect(results.score(@david.id).round(1)).to eq 0.9
        expect(results.score(@elaine.id).round(1)).to eq 0.4
      end
    end
  end

  context '.mark' do
  end
end

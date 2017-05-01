require 'rails_helper'

RSpec.describe CalculatePaScoresService, type: :model do

  it 'initialize sets the default marking algorithm if not defined' do
    iteration = create :iteration
    create :game_setting, assignment: iteration.assignment, marking_algorithm_id: 666

    service = CalculatePaScoresService.new iteration
    expect(service.marking_klass).to eq Marking::Algorithms::WebPaMarkingAlgorithm
  end

  context "before iteration's deadline" do
    before :each do
      @iteration = build :iteration, start_date: DateTime.now, deadline: DateTime.now + 1.year
      @iteration.save validate: false
      create :game_setting, assignment: @iteration.assignment
      @service = CalculatePaScoresService.new(@iteration)
    end

    describe '#call' do
      it 'returns nil if iteration is not finished' do
        expect(@service.call).to be_falsy
      end
    end

    it '#can_mark? returns false' do
      expect(@service.can_mark?).to be_falsy
    end
  end

  context "after iteration's deadline" do
    before :each do
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

      create :game_setting, assignment: @iteration.assignment
      @service = CalculatePaScoresService.new(@iteration)
    end

    describe '#call' do
      it 'creates IterationMark for each student' do
        Timecop.travel @iteration.deadline + 1.day do
          expect(@service.can_mark?).to be_truthy

          expect {
            @service.call
          }.to change { IterationMark.count }.by 5
        end
      end
    end

    it '#can_mark? returns true if not marked before' do
      Timecop.travel @iteration.deadline + 1.day do
        expect(@service.can_mark?).to be_truthy
      end
    end

    it '#can_mark? returns false if marked before' do
      Timecop.travel @iteration.deadline + 1.day do
        expect(@service.can_mark?).to be_truthy
        @iteration.update(is_marked: true)

        service = CalculatePaScoresService.new(@iteration)
        expect(service.can_mark?).to be_falsy
      end
    end
  end
end

FactoryGirl.define do
  factory :peer_assessment do
    association :pa_form, factory: :pa_form
    association :submitted_by, factory: :student_confirmed
    association :submitted_for, factory: :student_confirmed
    date_submitted { pa_form.start_date + 2.hours }
    answers { [{ question_id: 1, answer: 'Something' }, { question_id: 2, answer: 'A guy' }, { question_id: 3, answer: 'Yesterwhatever' }, { question_id: 4, answer: 'You know where' }, { question_id: 5, answer: 'Because' }] }

    after :build do |obj|
      project = FactoryGirl.create(:project, assignment: obj.pa_form.assignment)
      create(:students_project, student: obj.submitted_by, project: project) unless obj.submitted_by.teammates.include? obj.submitted_for
      create(:students_project, student: obj.submitted_for, project: project) unless obj.submitted_for.teammates.include? obj.submitted_by
    end

    factory :peer_assessment_unsubmitted do
      date_submitted nil
    end
  end
end

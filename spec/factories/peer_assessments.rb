FactoryBot.define do
  factory :peer_assessment do
    association :pa_form, factory: :pa_form
    association :submitted_by, factory: :student_confirmed
    association :submitted_for, factory: :student_confirmed
    date_submitted { pa_form.start_date + 2.hours }
    answers { [{ question_id: 1, answer: 'Something' }, { question_id: 2, answer: 'A guy' }, { question_id: 3, answer: 'Yesterwhatever' }, { question_id: 4, answer: 'You know where' }, { question_id: 5, answer: 'Because' }] }

    factory :peer_assessment_with_callback do
      after :build do |obj|
        next unless obj.submitted_by && obj.submitted_for

        next if obj.pa_form
                .assignment
                .students_projects
                .where(student_id: [obj.submitted_by, obj.submitted_for])
                .select(:project_id)
                .exists?

        project = create(:project, assignment: obj.pa_form.assignment)
        create(:students_project, student: obj.submitted_by, project: project)
        create(:students_project, student: obj.submitted_for, project: project)
      end
    end

    factory :peer_assessment_unsubmitted do
      date_submitted { nil }
    end
  end
end

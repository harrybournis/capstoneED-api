FactoryBot.define do
  factory :project_evaluation do
    user { FactoryBot.create(:student) }
    project do |obj|
      @now = DateTime.now
      lec = FactoryBot.create(:lecturer)
      unit = FactoryBot.create(:unit, lecturer: lec)
      assignment = FactoryBot.create(:assignment, lecturer: lec, start_date: @now, end_date: @now + 1.month )
      project = FactoryBot.create(:project, assignment: assignment)
      create :students_project, student: user, project: project
      project
    end
    iteration { FactoryBot.create(:iteration, assignment: project.assignment, start_date: @now, deadline: @now + 28.days) }
    percent_complete { rand 10..93 }
    date_submitted nil
    feelings_average { rand -60..90 }
    factory :project_evaluation_lecturer do
      user { FactoryBot.create(:lecturer) }
      project do |obj|
        @now = DateTime.now
        unit = FactoryBot.create(:unit, lecturer: user)
        assignment = FactoryBot.create(:assignment, lecturer: user, start_date: @now, end_date: @now + 1.month )
        FactoryBot.create(:project, assignment: assignment)
      end
    end

    factory :project_evaluation_seeder do

    end
  end
end

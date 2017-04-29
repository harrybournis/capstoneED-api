FactoryGirl.define do
  factory :project_evaluation do
    user { FactoryGirl.create(:student) }
    project do |obj|
      @now = DateTime.now
      lec = FactoryGirl.create(:lecturer)
      unit = FactoryGirl.create(:unit, lecturer: lec)
      assignment = FactoryGirl.create(:assignment, lecturer: lec, start_date: @now, end_date: @now + 1.month )
      project = FactoryGirl.create(:project, assignment: assignment)
      create :students_project, student: user, project: project
      project
    end
    iteration { FactoryGirl.create(:iteration, assignment: project.assignment, start_date: @now, deadline: @now + 28.days) }
    percent_complete (10..93).to_a.sample
    date_submitted nil
    feelings_average { rand -60..90 }
    factory :project_evaluation_lecturer do
      user { FactoryGirl.create(:lecturer) }
      project do |obj|
        @now = DateTime.now
        unit = FactoryGirl.create(:unit, lecturer: user)
        assignment = FactoryGirl.create(:assignment, lecturer: user, start_date: @now, end_date: @now + 1.month )
        FactoryGirl.create(:project, assignment: assignment)
      end
    end

    factory :project_evaluation_seeder do

    end
  end
end

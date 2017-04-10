FactoryGirl.define do
  factory :log_point do
  	points { [10, 5, 20, 50].sample }
  	date { DateTime.now }
  	log_id 1
    project { create :project }	
    students_project do 
      create :students_project, project: project
    end
  end
end

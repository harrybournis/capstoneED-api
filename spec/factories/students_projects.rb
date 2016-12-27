FactoryGirl.define do
  factory :students_project, class: JoinTables::StudentsProject do
  	association :project, factory: :project
  	association :student, factory: :student
  	nickname { "wolverine#{rand(1000).to_s}" }

  	after :build do |obj|
  		obj.project.students << obj.student
  	end
  end
end

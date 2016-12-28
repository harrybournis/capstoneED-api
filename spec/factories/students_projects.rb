FactoryGirl.define do
  factory :students_project, class: JoinTables::StudentsProject do
  	association :project, factory: :project
  	association :student, factory: :student
  	nickname { "wolverine#{rand(1000).to_s}" }

  	after :build do |obj|
  		obj.add_log({ date_worked: (DateTime.now - 1.day).to_i, time_worked: 10.hours.to_i, stage: 'Analysis', text: 'Worked on database and use cases' })
  	end
	end
end

FactoryBot.define do
  factory :extension do
  	extra_time { 2.days.to_i }
  	association :project, factory: :project
		association :pa_form, factory: :pa_form
  end
end

FactoryGirl.define do
	factory :pa_form, class: PAForm do
    questions ['What?', 'Who?', 'When?', 'Where?','Why?']
    association :iteration, factory: :iteration
	end
end

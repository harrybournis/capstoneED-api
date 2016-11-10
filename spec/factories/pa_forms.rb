FactoryGirl.define do
	factory :pa_form, class: PAForm do
    questions ['What?', 'Who?', 'When?', 'Where?','Why?']

    association :iteration, factory: :iteration

    start_offset { 2.days.to_i }
    end_offset { 5.days.to_i }
	end
end

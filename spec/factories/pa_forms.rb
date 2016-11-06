FactoryGirl.define do
	factory :pa_form, class: PAForm do
    questions ['What?', 'Who?', 'When?', 'Where?','Why?']

    association :iteration, factory: :iteration

		start_date do
			if iteration
				iteration.start_date
			else
				DateTime.now + 1.months + (100*rand())
			end
		end

		deadline   do
			if iteration
				iteration.deadline
			else
				DateTime.now + 1.year + (100*rand())
			end
		end


	end
end

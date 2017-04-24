class IterationSerializer < Base::BaseSerializer
	attributes :name, :start_date, :deadline, :assignment_id
	# has_one :pa_form
end

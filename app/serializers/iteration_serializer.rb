class IterationSerializer < Base::BaseSerializer
	attributes :name, :start_date, :deadline
	has_one :pa_form
end

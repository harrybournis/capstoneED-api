class AssignmentSerializer < Base::BaseSerializer
  attributes :start_date, :end_date

  attribute :href do
  	"/assignments/#{object.id}"
  end
end

class AssignmentSerializer < Base::BaseSerializer
  attributes :start_date, :end_date, :description

  attribute :href do
  	"/assignments/#{object.id}"
  end
end

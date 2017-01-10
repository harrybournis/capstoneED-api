class AssignmentSerializer < Base::BaseSerializer
  attributes :start_date, :end_date, :name, :unit_id

  attribute :href do
  	"/assignments/#{object.id}"
  end
end

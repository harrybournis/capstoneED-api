class ProjectSerializer < Base::BaseSerializer
  attributes :start_date, :end_date, :description

  attribute :href do
  	"/projects/#{object.id}"
  end
end

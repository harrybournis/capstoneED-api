class Project::ProjectSerializer < Base::BaseSerializer
  attributes :id, :start_date, :end_date, :description

  attribute :href do
  	"/projects/#{object.id}"
  end

end

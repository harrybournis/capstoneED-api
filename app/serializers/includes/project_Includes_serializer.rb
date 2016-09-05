class Includes::ProjectIncludesSerializer < Base::BaseIncludesSerializer
  attributes :id, :start_date, :end_date, :description

  attribute :href do
  	"/projects/#{object.id}"
  end

  has_one :unit, 		serializer: UnitSerializer
  has_many :teams, 	serializer: TeamSerializer
end

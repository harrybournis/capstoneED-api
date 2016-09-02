class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :description

  has_one :unit
  has_many :teams do
  	#binding.pry
  end

end

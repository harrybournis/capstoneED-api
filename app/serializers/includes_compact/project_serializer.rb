class IncludesCompact::ProjectSerializer < ProjectSerializer
  has_one :unit, 		serializer: Base::BaseSerializer
  has_many :teams, 	serializer: Base::BaseSerializer
end

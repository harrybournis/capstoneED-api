class IncludesCompact::UnitsController < UnitsController
	belongs_to 	:department, serializer: Base::BaseSerializer
	has_many 		:projects, serializer: Base::BaseSerializer
end

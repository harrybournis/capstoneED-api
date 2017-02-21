class IncludesCompact::AssignmentSerializer < AssignmentSerializer
  has_one 	:unit, 				serializer: Compact::UnitSerializer
  has_many 	:projects, 		serializer: Compact::ProjectSerializer
  has_many 	:iterations, 	serializer: Base::BaseSerializer
  has_many  :students, 		serializer: Base::BaseSerializer
  has_one 	:lecturer, 		serializer: Base::BaseSerializer
  has_many 	:pa_forms, 		serializer: Base::BaseSerializer
end

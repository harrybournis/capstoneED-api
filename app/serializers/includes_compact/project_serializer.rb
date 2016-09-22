class IncludesCompact::ProjectSerializer < ProjectSerializer
  has_one 	:unit, 				serializer: Base::BaseSerializer
  has_many 	:teams, 			serializer: Base::BaseSerializer
  has_many 	:iterations, 	serializer: Base::BaseSerializer
  has_many  :students, 		serializer: Base::BaseSerializer
  has_one 	:lecturer, 		serializer: Base::BaseSerializer
  has_many 	:pa_forms, 		serializer: Base::BaseSerializer
end

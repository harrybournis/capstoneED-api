class Includes::ProjectSerializer < ProjectSerializer
  has_one		:unit
  has_many 	:teams
  has_many 	:iterations
  has_many  :students
  has_one 	:lecturer
  has_many 	:pa_forms
end

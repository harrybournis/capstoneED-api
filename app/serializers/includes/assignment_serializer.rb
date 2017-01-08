class Includes::AssignmentSerializer < AssignmentSerializer
  has_one		:unit
  has_many 	:iterations
  has_many  :students
  has_one 	:lecturer
  has_many 	:pa_forms
  has_many 	:projects
end

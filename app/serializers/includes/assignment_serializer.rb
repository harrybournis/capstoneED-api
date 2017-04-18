class Includes::AssignmentSerializer < AssignmentSerializer
  has_one		:unit
  has_many 	:iterations
  has_many  :students
  has_one 	:lecturer
  has_many 	:pa_forms
  has_many 	:projects

  def iterations
    object.iterations.sort_by &:start_date
  end
end

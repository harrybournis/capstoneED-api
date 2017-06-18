class ScoredIterationStudentSerializer < IterationSerializer
  attribute :pa_score

  def pa_score
    object.iteration_marks.each do |im|
      return im.pa_score if im.student_id == current_user.id
    end
  end
end

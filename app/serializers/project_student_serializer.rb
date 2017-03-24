class ProjectStudentSerializer < ProjectSerializer
  attribute :nickname

  def nickname
    # current_user.nickname_for_project_id(object.id)
    object.students_projects.each do |sp|
      return sp.nickname if sp.student_id == current_user.id
    end
    'NO name'
  end
end

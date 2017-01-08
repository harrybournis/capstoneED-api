class ProjectStudentSerializer < ProjectSerializer
  attribute :nickname

  def nickname
  	current_user.nickname_for_project_id(object.id)
  end
end

class PaFormSerializer < Base::BaseSerializer
  attributes :id, :iteration_id, :questions, :start_date, :deadline
  attribute :extension_until, if: :extension_until_condition
  attribute :extensions, if: :extension_condition

  def extension_until
    object.deadline_with_extension_for_project(@extension.project)
  end

  def extension_until_condition
    #scope.type == 'Student' && @extension = Extension.where(deliverable_id: object.id, project_id: scope.projects.ids)[0]
    scope.type == 'Student' && @extension =
      Extension.where(deliverable_id: object.id, project_id: Project.joins(:students_projects).select(:id).where(['students_projects.student_id = ?', scope.id]))[0]
  end

  def extension_condition
    scope.type == 'Lecturer' && scope.extensions.where(deliverable_id: object.id).any?
  end

  def extensions
    scope.extensions.where(deliverable_id: object.id)
  end
end

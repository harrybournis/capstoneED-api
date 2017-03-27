class PaFormSerializer < Base::BaseSerializer
  attributes :id, :iteration_id, :questions, :start_date, :deadline, :project_id
  attribute :extension_until, if: :extension_until_condition
  attribute :extensions, if: :extension_condition

  def project_id
    object.projects.each do |project|
      project.students_projects.each do |student|
        return project.id if student.student_id == scope.id
      end
    end
  end

  def extension_until
    object.deadline_with_extension_for_project(@extension.project)
  end

  def extension_until_condition
    # scope.type == 'Student' && @extension = Extension.where(deliverable_id: object.id, project_id: scope.projects.ids)[0]
    scope.type == 'Student' && @extension =
      Extension.where(deliverable_id: object.id, project_id: Project.joins(:students_projects).select(:id).where(['students_projects.student_id = ?', scope.id]))[0]
  end

  def extension_condition
    scope.type == 'Lecturer' && scope.extensions.where(deliverable_id: object.id).any?
  end

  def extensions
    scope.extensions.where(deliverable_id: object.id)
  end

  def questions
    question_types = QuestionType.all

    object.questions.tap do |questions|
      questions.each do |q|
        question_types.each do |t|
          if t.id == q['type_id']
            q.merge!(ActiveModelSerializers::SerializableResource.new(t, {serializer: QuestionTypeSerializer})
                                                                             .as_json)
          end
        end
      end
      questions.to_json
    end
  end
end

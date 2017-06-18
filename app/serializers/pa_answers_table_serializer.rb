class PaAnswerTableSerializer < ActiveModel::Serializer
  atributes :id, :project_name, :columns, :rows

  def id
    object.project.id
  end

  def project_name
    object.project.project_name
  end

  def columns
    object.student_ids
  end

  def rows
  end

  type 'marks'
end

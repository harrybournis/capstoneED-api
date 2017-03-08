class QuestionTypeSerializer < ActiveModel::Serializer
  attributes :id, :question_type, :friendly_name

  def question_type
    object.category
  end
end

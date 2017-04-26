class QuestionSerializer < Base::BaseSerializer
	attributes :type_id, :text
  has_one :question_type

  def type_id
    object.question_type_id
  end
end

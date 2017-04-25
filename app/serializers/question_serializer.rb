class QuestionSerializer < Base::BaseSerializer
	attributes :question_type_id, :text
  has_one :question_type
end

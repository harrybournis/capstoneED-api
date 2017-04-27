class FormTemplateSerializer < Base::BaseSerializer
  attributes :name, :lecturer_id
  attribute :questions

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

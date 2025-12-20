# Helper methods for better integrating dry-validations with
# active model.
#
module ValidationHelpers
  extend ActiveSupport::Concern

  def question_format_validation
    return unless questions.present?

    q_types = QuestionType.all.select(:id).map { |q| q.id }

    schema = Dry::Schema.Params do
      config.messages.backend = :i18n

      required(:questions).array(:hash) do
        required(:question_id).filled(:integer)
        required(:text).filled(:string)
        required(:type_id).filled(:integer, included_in?: q_types)
      end
    end

    result = schema.call(questions: questions)

    result_errors_to_active_model :questions, result
  end

  # Take the errors from dry-validations Result object,
  # and add them to active model errors.
  #
  # @param key [Symbol] The key that should be used when adding
  #   the error to active model errors.
  # @param result [Dry::Validation::Result] The result of
  #   validation.
  #
  def result_errors_to_active_model(key, result)
    unless result.success?
      result.errors(full: true).messages.each do |message|
        errors.add(key, message.text)
      end
    end
  end
end

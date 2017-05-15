# A form template is a collection of questions that a Lecturer can use
# to create a new PA Form fast. Belongs to a single Lecturer.
#
# @author [harrybournis]
#
# @!attribute lecturer_id
#   @return [Integer] The id of the lecturer that created the form_template
# @!attribute name
#   @return [String] The name that the lecturer has given to identify the form template.
#
# @!attribute questions
#   @return [jsonb] The questions for the PA Form
#
class FormTemplate < ApplicationRecord
  belongs_to :lecturer
  validates_presence_of :name, :questions, :lecturer
  validate :format_of_questions

  # Override questions setter to receive an array and format and save it
  # in the desired format.
  #
  # @param  [Array]   questions_param The questions of the PAform as an
  #                   Array in the order they are supposed to appear.
  def questions=(questions_param)
    super nil ; return unless questions_param.is_a?(Array) && questions_param.any?
    jsonb_array = []

    questions_param.each_with_index do |elem, i|
      super nil ; return unless elem['text'].present? && elem['type_id'].present?
      jsonb_array << { 'question_id' => i + 1,
                       'text' => elem['text'],
                       'type_id' => elem['type_id'] }
    end
    super jsonb_array
  end

  private

  # Validation of the questions format
  #
  def format_of_questions
    return unless questions.present?

    q_types = QuestionType.all.select(:id).map { |q| q.id }

    schema = Dry::Validation.JSON do
      configure do
        config.input_processor = :form
        config.type_specs = true
        config.messages = :i18n
      end

      each do
        schema do
          required(:question_id, :int).value(:int?)
          required(:text, :int).value(:str?)
          required(:type_id, :int).value(:int?, included_in?: q_types)
        end
      end
    end

    result = schema.call(questions)

    errors.add(:questions, result) unless result.success?
  end
end

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
  include ValidationHelpers

  belongs_to :lecturer
  validates_presence_of :name, :questions, :lecturer
  validate :question_format_validation

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
end

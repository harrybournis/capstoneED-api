
# Each lecturer has a collection of questions that they can
# view and reuse when they create a new Pa Form. A question
# does not hold an logic about the expected question_type and
# the answer, and it only functions as storage of the lecturer's
# past questions.
#
# @!attribute [r] text
#   @return [String] The text of the question
#
# @!attribute [r] lecturer_id
#   @return [Integer] The id of the Lecturer that created the question.
#
class Question < ApplicationRecord
  belongs_to :lecturer
  # has_many :questions_sections, class_name:  QuestionsSection
  # has_many :sections, through: :questions_sections

  validates_presence_of :text, :lecturer_id
end

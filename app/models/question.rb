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
# @!attribute [r] question_type_id
#   @return [Integer] The id of the type of the question.
#
class Question < ApplicationRecord
  belongs_to :lecturer
  belongs_to :question_type

  validates_presence_of :text, :lecturer_id, :question_type_id
end

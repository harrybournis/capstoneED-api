
# Question type indicates in which way a question in a PaForm should
# be anwered in the frontent. It only works as an indicator for the
# client, and does not currently hold any validation logic about the
# format of the answer.
#
# It has a category, and a friendly_name, which is used to display
# it in the client.
#
class QuestionType < ApplicationRecord
  has_many :questions

  validates_presence_of :category, :friendly_name
end

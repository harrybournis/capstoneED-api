# Feelings are part of project evaluation. In each evaluation, the user
# has to select one of the predefined feelings. Each feeling also has
# a value associated with it. Currently, feelings can have either values of
# either 0 (a negative feeling), and a 1 (a positive feeling). However,
# the value field accepts any integer, and it is possible to define
# different values for each feeling, allowing them to be processed in
# more complicated ways.
#
# @!attribute name
#   @return [String] The name of the feelings. It will probably be seen
#     by the users.
#
# @!attribute value
#   @return [Integer] The value associated with the feeling. It is currently
#     0 (for negative feelings), or 1 (for positive feelings).
#
class Feeling < ApplicationRecord
  has_many :project_evaluations, through: :feelings_project_evaluations
  has_many :feelings_project_evaluations

  validates_presence_of :name, :value
  validates_uniqueness_of :name
  validates_inclusion_of :value, in: [-1,1]
end

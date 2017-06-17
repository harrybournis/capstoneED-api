# Created when a student creates their account. Contains their total XP and
# their level in the game.
#
# @!attribute student_id
#   @return [Integer] The id of the student that the profile belongs to
#
# @!attribute total_xp
#   @return [Integer] The total number of XP gained by the student
# @!attribute level
#   @return [Integer] The student's current level. It can be calculated from their XP,
#     but cached for easier access.
#
class StudentProfile < ApplicationRecord
  include StudentProfile::Xpable

  belongs_to :student
end

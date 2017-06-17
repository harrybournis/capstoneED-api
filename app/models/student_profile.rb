# Created when a student creates their account. Contains their total XP and their level
# in the game. Also contains logic to calculate their level according to their XP,
# and logic to calculate the XP needed to reach a particular level.
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
  belongs_to :student
  validates_presence_of :total_xp, :level

  # Modifies the XP to get the level
  COEFFICIENT = 0.02
  MIN_LEVEL = 1
  MAX_LEVEL = 7

  # Calculates the current level of the student according to their
  # total_xp, and assigns it to
  # as the current level. Returns the MIN_LEVEL if the result is less
  # than it, and the MAX_LEVEL if it is bigger.
  #
  # @return [Integer] The current level of the student
  #
  def calculate_level(coefficient = COEFFICIENT)
    level = (Math.sqrt(coefficient * self.total_xp)).to_i
    self.level = level
    return MIN_LEVEL if level <= 0
    return MAX_LEVEL if level > MAX_LEVEL
    level
  end

  # Calculates the remaining xp till the next level is reached.
  #
  # @return [Integer] The number of xp needed to reach the next level
  def calculate_xp_to_next_level(coefficient = COEFFICIENT)
    calculate_xp_to_level(self.level + 1, coefficient) - self.total_xp
  end

  private

  # Calculates the nuber of xp needed to reach the provided level
  #
  # @param level [Integer] The level that needs to be reached
  # @return [Integer] The number of xp needed to reach the level
  #
  def calculate_xp_to_level(level, coefficient = COEFFICIENT)
    (level ** 2) / coefficient
  end
end

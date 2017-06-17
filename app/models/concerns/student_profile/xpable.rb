# StudentProfile mixin. Contains logic on handling XP and levels.
# Contains logic to calculate their level according to their XP,
# and logic to calculate the XP needed to reach a particular level.
#
module StudentProfile::Xpable
  extend ActiveSupport::Concern

  included do
    validates_presence_of :total_xp, :level
  end


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

    if level <= 0
      self.level = MIN_LEVEL
      return MIN_LEVEL
    end
    if level > MAX_LEVEL
      self.level = MAX_LEVEL
      return MAX_LEVEL if level > MAX_LEVEL
    end

    self.level = level
    level
  end

  # Calculates the remaining xp till the next level is reached.
  #
  # @return [Integer] The number of xp needed to reach the next level
  #
  def calculate_xp_to_next_level(coefficient = COEFFICIENT)
    (calculate_xp_to_level(self.level + 1, coefficient) - self.total_xp).to_i
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

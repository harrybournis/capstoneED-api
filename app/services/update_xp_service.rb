# Handles the update of users XP after being awarded points.
# Takes pointsboard and saves the points earned as XP.
class UpdateXpService
  # Constructor
  def initialize(pointsboard)
    @pointsboard = pointsboard
    @student_profile = pointsboard.student.student_profile
  end

  # Saves the total points earned as xp in the student profile
  #
  # @return [PointsBoard] The pointsboard containing the xp gained
  #
  def call
    new_xp = @pointsboard.total_points
    @student_profile.total_xp += new_xp
    @student_profile.calculate_level
    @pointsboard.xp = new_xp

    unless @student_profile.save
      @pointsboard.add_error(:xp, 'could not be updated')
    end
    @pointsboard
  end
end

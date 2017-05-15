# Project mixin. Methods that provide the points functionality to the Project.
# Includes the associations with log_points, peer_assessment_points and
# project_evaluation_points tables.
module Project::Awardable
  extend ActiveSupport::Concern

  included do
    has_many    :log_points
    has_many    :peer_assessment_points
    has_many    :project_evaluation_points
  end

  # The total points earned by the Students of this Project.
  #
  # @return [Integer] The sum of the Students Points.
  #
  def team_points
    return @total if @total
    # This version is implemented as a database sum operation,
    # but it cannot be eager loaded so it results in 5 more
    # database queries:
    #
    # students_projects.select(:points).sum :points

    # This version programmatically adds the points:
    total = 0
    students_projects.each { |s| total += s.points }
    @total = total
    total
  end

  # The average points earned by the Students of this Project.
  #
  # @return [Integer] The average of the Students Points.
  #
  def team_average
    # This version is implemented as a database AVG operation,
    # but it cannot be eager loaded so it results in an extra
    # database query for each project:
    #
    # avg = students_projects.select(:points).average :points
    # avg ? avg.round : 0

    # This version programmatically finds the average of the points:
    #self.reload
    no_of_students = self.students_projects.length
    return 0 if no_of_students == 0
    total = 0
    self.students_projects.each { |s| total += s.points }
    (total / no_of_students).round
  end
end

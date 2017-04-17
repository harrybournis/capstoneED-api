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
  def total_points
    students_projects.select(:points).sum :points
  end

  # The average points earned by the Students of this Project.
  #
  # @return [Integer] The average of the Students Points.
  #
  def average_points
    (students_projects.select(:points).average :points).round
  end
end

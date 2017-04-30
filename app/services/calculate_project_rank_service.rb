# Called in order to calcluate the points of
# each project in an assignemnt and rank them.
# It updated the rank in the database for each
# project.
#
class CalculateProjectRankService
  # Takes an asignment whose projects
  # will be ranked.
  #
  # @param assignment [Assignment] The assignment
  #   whose projects will be ranked.
  #
  def initialize(assignment)
    @assignment = assignment
  end

  # Execute the service's action. For each
  # project in the Assignment, it sums the points
  # of each Student of the team and compares them.
  # Returns a hash whose keys are the ids of each
  # project.
  #
  # @return [Hash<int->int>] A hash whose keys
  #   are the ids of each Project, and the value
  #   is their rank number.
  #
  def call
    return nil unless @assignment.projects && !@assignment.projects.empty?
    projects = @assignment.projects.sort_by(&:team_points).reverse
    @projects_sorted = projects
    result = {}

    rank = 1
    i = 0
    projects.map do |project|
      i += 1
      if project.team_points != projects[i-2].team_points
        rank = i
      end
      result[project.id] = rank
    end

    @result = result
  end

  # Updates the rank in the database based on the results
  # hash. Returns nil if no results have been calculated or
  # updating the records in database fails.
  #
  # @return [Boolean] True if update successful, nil
  #   if errors.
  def update!
    Project.transaction do
      @projects_sorted.each { |project| project.update!(rank: @result[project.id]) }
    end
    true
  rescue
    nil
  end
end

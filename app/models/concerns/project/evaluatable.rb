module Project::Evaluatable

	extend ActiveSupport::Concern

  # Project Health. The mean of the iteration_health of all iterations
  def project_health
    sum = 0
    self.iterations.each { |iteration| sum += iteration.iteration_health }
    (sum / self.iterations.length).round
  end

  # Team Health (static number right now. CHANGE)
  def team_health
    75
  end

end

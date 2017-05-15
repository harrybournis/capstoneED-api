# Background job that scores comleted Peer Assessments
class PaScoreJob < ActiveJob::Base
  queue_as :default

  # Execute the job. Finds all iterations that have finished, and have
  # not yet been scored and passes scores them.
  def perform
    iterations = Iteration.where("is_scored = false and deadline <= ?", DateTime.now)
    iterations.each do |iteration|
      CalculatePaScoresService.new(iteration).call
    end
  end
end

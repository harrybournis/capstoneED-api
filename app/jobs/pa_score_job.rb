class PaScoreJob < ActiveJob::Base
  queue_as :default

  def perform
    iterations = Iteration.where("is_scored = false and deadline <= ?", DateTime.now)
    iterations.each do |iteration|
      CalculatePaScoresService.new(iteration).call
    end
  end
end

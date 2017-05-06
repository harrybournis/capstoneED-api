class PaScoreJob < ActiveJob::Base
  queue_as :default

  def perform
    iterations = Iteration.active.where(is_scored: false)
    iterations.each do |iteration|
      CalculatePaScoresService.new(iteration).call
    end
  end
end

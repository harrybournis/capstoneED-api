class PaScoreJob < ActiveJob::Base
  queue_as :default

  def perform
    Iteration.where(is_scored: false, false
  end
end

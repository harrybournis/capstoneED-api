require 'rails_helper'

RSpec.describe PaScoreJob, type: :job do
  subject(:job) { described_class.perform_later }

  before :each do
    ActiveJob::Base.queue_adapter = :test
  end
  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class)
      .on_queue("default")
  end
end

require 'rails_helper'

RSpec.describe Decorators::Log do

  describe 'something' do
    it 'is  successfully' do
      sp = create :students_project

      entry = sp.logs[0]
      log = Decorators::Log.new(1,
                                sp.project_id,
                                entry[:date_worked],
                                entry[:time_submitted],
                                entry[:time_worked],
                                entry[:stage],
                                entry[:text])
      expect(log).to be_truthy
    end
end
end

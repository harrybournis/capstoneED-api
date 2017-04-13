module Decorators
  ## Decorates the Student with their nickname for a Specific Project
  class Log
    include ActiveModel::Serialization

    attr_reader :id, :project_id, :date_worked, :date_submitted, :time_worked, :stage, :text

    def initialize(id, project_id, date_worked, date_submitted, time_worked, stage, text)
      @id = id
      @project_id = project_id
      @date_worked = date_worked
      @date_submitted = date_submitted
      @time_worked = time_worked
      @stage = stage
      @text = text
    end
  end
end

module Waterfall
  extend ActiveSupport::Concern

  class Rollback < StandardError; end

  def with_transaction(&block)
    ActiveRecord::Base.transaction(requires_new: true) do
      yield
      on_dam do
        raise Waterfall::Rollback
      end
    end
  rescue Waterfall::Rollback
    self
  end
end

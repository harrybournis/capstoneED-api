class LogSerializer < ActiveModel::Serializer
  attributes :date_worked, :time_worked, :date_submitted, :stage, :text

  type 'log_entry'
end

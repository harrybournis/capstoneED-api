class QuestionType < ApplicationRecord
  # id            integer
  # category      string
  # friendly_name string

  validates_presence_of :category, :friendly_name
end

module JoinTables
  ## Join table for Question and Section
  class QuestionsSection < ApplicationRecord
    # Attributes
    # question_id   :integer
    # section_id    :integer

    # Associations
    belongs_to :question
    belongs_to :section

    # Validations
    validates_presence_of :question_id, :section_id
  end
end

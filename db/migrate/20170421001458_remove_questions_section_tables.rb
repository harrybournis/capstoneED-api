class RemoveQuestionsSectionTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :questions_sections
    drop_table :sections
  end
end

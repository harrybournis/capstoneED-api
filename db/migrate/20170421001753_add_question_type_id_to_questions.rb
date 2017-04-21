class AddQuestionTypeIdToQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :questions, :question_type_id, :integer
    remove_column :questions, :category
    add_index :questions, :question_type_id
  end
end

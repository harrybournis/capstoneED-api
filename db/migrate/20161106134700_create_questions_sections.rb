class CreateQuestionsSections < ActiveRecord::Migration[5.0]
  def change
    create_table :questions_sections do |t|
      t.integer :question_id
      t.integer :section_id

      t.timestamps
    end
    add_index :questions_sections, :question_id
    add_index :questions_sections, :section_id
  end
end

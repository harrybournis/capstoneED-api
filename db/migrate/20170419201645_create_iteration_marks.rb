class CreateIterationMarks < ActiveRecord::Migration[5.0]
  def change
    create_table :iteration_marks do |t|
      t.integer :student_id
      t.integer :iteration_id
      t.integer :mark
      t.decimal :pa_score

      t.timestamps
    end
    add_index :iteration_marks, :student_id
    add_index :iteration_marks, :iteration_id
  end
end

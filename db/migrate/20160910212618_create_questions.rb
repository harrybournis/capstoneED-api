class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.string :type
      t.text	:text
      t.integer :lecturer_id

      t.timestamps
    end
  end
end

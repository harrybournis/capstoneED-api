class IndexProjectIdOnQuestions < ActiveRecord::Migration[5.0]
  def change
  	add_index :questions, :lecturer_id
  end
end

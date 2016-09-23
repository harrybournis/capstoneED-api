class RemoveQuestionsOrderFromPaForms < ActiveRecord::Migration[5.0]
  def change
  	remove_column :pa_forms, :questions_order
  end
end

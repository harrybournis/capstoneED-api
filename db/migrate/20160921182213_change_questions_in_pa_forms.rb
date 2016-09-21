class ChangeQuestionsInPaForms < ActiveRecord::Migration[5.0]
  def change
  	change_column :pa_forms, :questions, :jsonb, default: {}, null: false
  end
end

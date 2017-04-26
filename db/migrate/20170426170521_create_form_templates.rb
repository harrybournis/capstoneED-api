class CreateFormTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :form_templates do |t|
      t.string :name
      t.jsonb :questions
      t.integer :lecturer_id

      t.timestamps
    end
    add_index :form_templates, :lecturer_id
  end
end

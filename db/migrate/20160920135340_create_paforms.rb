class CreatePaforms < ActiveRecord::Migration[5.0]
  def change
    create_table :pa_forms do |t|
      t.jsonb :questions, null: false, default: '{}'
      t.jsonb :questions_order, null: false, default: '{}'
      t.integer :iteration_id

      t.timestamps
    end
    add_index :pa_forms, :iteration_id
    add_index :pa_forms, :questions, using: :gin
    add_index :pa_forms, :questions_order, using: :gin
  end
end

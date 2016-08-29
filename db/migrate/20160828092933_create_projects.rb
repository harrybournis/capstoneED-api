class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.date :start_date
      t.date :end_date
      t.text :description
      t.references :unit, foreign_key: true
      t.integer :lecturer_id
      t.timestamps
    end

    add_index :projects, :lecturer_id
  end
end

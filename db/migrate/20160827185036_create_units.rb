class CreateUnits < ActiveRecord::Migration[5.0]
  def change
    create_table :units do |t|
      t.string :name
      t.string :code
      t.string :semester
      t.integer :year
      t.date :archived_at
      t.integer :department_id
      t.integer :lecturer_id

      t.timestamps
    end
    add_index :units, :department_id
    add_index :units, :lecturer_id
  end
end

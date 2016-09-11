class CreateIterations < ActiveRecord::Migration[5.0]
  def change
    create_table :iterations do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :deadline
      t.integer :project_id

      t.timestamps
    end
    add_index :iterations, :project_id
  end
end

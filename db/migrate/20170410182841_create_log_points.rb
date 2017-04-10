class CreateLogPoints < ActiveRecord::Migration[5.0]
  def change
    create_table :log_points do |t|
      t.integer :points
      t.integer :reason_id
      t.integer :student_id
      t.integer :log_id
      t.integer :project_id
      t.datetime :date

      t.timestamps
    end
    add_index :log_points, :reason_id
    add_index :log_points, :project_id
    add_index :log_points, :log_id
  end
end

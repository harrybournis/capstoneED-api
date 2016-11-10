class CreateExtensions < ActiveRecord::Migration[5.0]
  def change
    create_table :extensions do |t|
      t.datetime :extra_time
      t.integer :team_id
      t.integer :iteration_id

      t.timestamps
    end
    add_index :extensions, :team_id
    add_index :extensions, :iteration_id
  end
end

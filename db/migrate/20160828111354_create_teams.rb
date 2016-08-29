class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :logo
      t.string :enrollment_key
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end

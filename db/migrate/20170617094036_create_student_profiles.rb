class CreateStudentProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :student_profiles do |t|
      t.integer :student_id
      t.integer :total_xp, default: 0
      t.integer :level, default: 1

      t.timestamps
    end
    add_index :student_profiles, :student_id
  end
end

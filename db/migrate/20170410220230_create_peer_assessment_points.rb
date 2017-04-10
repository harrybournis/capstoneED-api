class CreatePeerAssessmentPoints < ActiveRecord::Migration[5.0]
  def change
    create_table :peer_assessment_points do |t|
      t.integer :points
      t.integer :reason_id
      t.integer :student_id
      t.integer :peer_assessment_id
      t.integer :project_id
      t.datetime :date

      t.timestamps
    end
    add_index :peer_assessment_points, :reason_id
    add_index :peer_assessment_points, :student_id
    add_index :peer_assessment_points, :peer_assessment_id
    add_index :peer_assessment_points, :project_id
  end
end

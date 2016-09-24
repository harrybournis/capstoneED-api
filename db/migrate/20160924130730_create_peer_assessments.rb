class CreatePeerAssessments < ActiveRecord::Migration[5.0]
  def change
    create_table :peer_assessments do |t|
      t.integer :pa_form_id
      t.integer :submitted_by_id
      t.integer :submitted_for_id
      t.datetime :date_submitted
      t.jsonb :answers

      t.timestamps
    end
    add_index :peer_assessments, :pa_form_id
    add_index :peer_assessments, :submitted_by_id
    add_index :peer_assessments, :submitted_for_id
  end
end

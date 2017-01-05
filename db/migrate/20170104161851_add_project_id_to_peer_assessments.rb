class AddProjectIdToPeerAssessments < ActiveRecord::Migration[5.0]
  def change
    add_column :peer_assessments, :project_id, :integer
    add_index :peer_assessments, :project_id
  end
end

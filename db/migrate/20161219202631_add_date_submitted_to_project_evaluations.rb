class AddDateSubmittedToProjectEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :project_evaluations, :date_submitted, :datetime
  end
end

class ChangeTablePaFormToDeliverable < ActiveRecord::Migration[5.0]
  def change
  	rename_table :pa_forms, :deliverables
  end
end

class ChangeExtensionsIterationIdToDeliverableId < ActiveRecord::Migration[5.0]
  def change
  	rename_column :extensions, :iteration_id, :deliverable_id
  end
end

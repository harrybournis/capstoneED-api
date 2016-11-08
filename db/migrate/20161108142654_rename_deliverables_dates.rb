class RenameDeliverablesDates < ActiveRecord::Migration[5.0]
  def change
  	rename_column :deliverables, :start_date, :start_offset
  	rename_column :deliverables, :deadline, :end_offset
  end
end

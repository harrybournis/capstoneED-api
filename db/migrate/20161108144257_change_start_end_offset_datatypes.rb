class ChangeStartEndOffsetDatatypes < ActiveRecord::Migration[5.0]
  def change
  	remove_column :deliverables, :start_offset
  	remove_column :deliverables, :end_offset
  	add_column :deliverables, :start_offset, :integer
  	add_column :deliverables, :end_offset, :integer
  end
end

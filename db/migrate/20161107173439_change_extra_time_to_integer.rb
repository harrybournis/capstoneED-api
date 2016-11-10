class ChangeExtraTimeToInteger < ActiveRecord::Migration[5.0]
  def change
  	remove_column :extensions, :extra_time

  	change_table :extensions do |t|
  		t.integer :extra_time
  	end
  end
end

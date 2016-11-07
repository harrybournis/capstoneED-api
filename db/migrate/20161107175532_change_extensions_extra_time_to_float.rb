class ChangeExtensionsExtraTimeToFloat < ActiveRecord::Migration[5.0]
  def change
  	change_column :extensions, :extra_time, :float
  end
end

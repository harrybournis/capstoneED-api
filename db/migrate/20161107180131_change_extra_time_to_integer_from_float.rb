class ChangeExtraTimeToIntegerFromFloat < ActiveRecord::Migration[5.0]
  def change
  	change_column :extensions, :extra_time, :integer
  end
end

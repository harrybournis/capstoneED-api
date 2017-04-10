class AddValueToFeelings < ActiveRecord::Migration[5.0]
  def change
    add_column :feelings, :value, :integer
  end
end

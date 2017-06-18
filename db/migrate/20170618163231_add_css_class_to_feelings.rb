class AddCssClassToFeelings < ActiveRecord::Migration[5.0]
  def change
    add_column :feelings, :css_class, :string
  end
end

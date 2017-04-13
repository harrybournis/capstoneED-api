class DropReasons < ActiveRecord::Migration[5.0]
  def change
    drop_table :reasons
  end
end

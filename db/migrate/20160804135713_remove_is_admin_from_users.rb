class RemoveIsAdminFromUsers < ActiveRecord::Migration[5.0]
  def change
  	remove_column :users, :is_admin
  end
end

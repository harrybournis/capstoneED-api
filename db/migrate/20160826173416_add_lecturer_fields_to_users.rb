class AddLecturerFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :position, :string
    add_column :users, :university, :string
  end
end

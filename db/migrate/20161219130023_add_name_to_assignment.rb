class AddNameToAssignment < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :name, :string
  end
end

class AddTypeToDeliverables < ActiveRecord::Migration[5.0]
  def change
    add_column :deliverables, :type, :string
  end
end

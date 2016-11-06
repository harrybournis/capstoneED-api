class AddStartDateDeadlineToPaForm < ActiveRecord::Migration[5.0]
  def change
    add_column :pa_forms, :start_date, :datetime
    add_column :pa_forms, :deadline, :datetime
  end
end

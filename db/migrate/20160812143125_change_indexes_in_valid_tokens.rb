class ChangeIndexesInValidTokens < ActiveRecord::Migration[5.0]
  def change
  	remove_column :active_tokens, :jti
  	add_index :active_tokens, :user_id
  end
end

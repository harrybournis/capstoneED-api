class AddUserIdToRevokedTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :revoked_tokens, :user_id, :integer
  end
end

class RemoveColumnRevokedTokensDevice < ActiveRecord::Migration[5.0]
  def change
  	remove_column :revoked_tokens, :device
  end
end

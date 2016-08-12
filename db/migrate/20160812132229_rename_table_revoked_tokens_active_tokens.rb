class RenameTableRevokedTokensActiveTokens < ActiveRecord::Migration[5.0]
  def change
  	rename_table :revoked_tokens, :active_tokens
  end
end

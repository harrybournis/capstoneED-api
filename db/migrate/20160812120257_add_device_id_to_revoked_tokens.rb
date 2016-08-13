class AddDeviceIdToRevokedTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :revoked_tokens, :device, :string
  end
end

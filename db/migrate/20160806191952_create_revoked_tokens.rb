class CreateRevokedTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :revoked_tokens do |t|
      t.string :jti
      t.datetime :exp

      t.timestamps
    end
    add_index :revoked_tokens, :jti
  end
end

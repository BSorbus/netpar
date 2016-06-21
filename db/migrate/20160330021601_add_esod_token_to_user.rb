class AddEsodTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :esod_token, :string
    add_column :users, :esod_token_expired_at, :datetime
  end
end

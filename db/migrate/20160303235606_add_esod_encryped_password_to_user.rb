class AddEsodEncrypedPasswordToUser < ActiveRecord::Migration
  def change
    add_column :users, :esod_encryped_password, :string
  end
end

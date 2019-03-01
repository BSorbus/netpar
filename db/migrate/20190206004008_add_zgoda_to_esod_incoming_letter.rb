class AddZgodaToEsodIncomingLetter < ActiveRecord::Migration
  def change
    add_column :esod_incoming_letters, :zgoda, :integer, default: 1
  end
end

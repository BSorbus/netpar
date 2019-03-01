class AddTajemnicaToEsodIncomingLetter < ActiveRecord::Migration
  def change
    add_column :esod_incoming_letters, :tajemnica, :integer, default: 1
  end
end

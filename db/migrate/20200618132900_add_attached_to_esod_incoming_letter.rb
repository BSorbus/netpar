class AddAttachedToEsodIncomingLetter < ActiveRecord::Migration
  def change
    add_reference :esod_incoming_letters, :document, foreign_key: false
  end
end

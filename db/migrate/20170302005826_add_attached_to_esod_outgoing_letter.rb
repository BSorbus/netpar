class AddAttachedToEsodOutgoingLetter < ActiveRecord::Migration
  def change
    add_reference :esod_outgoing_letters, :document, foreign_key: false
  end
end

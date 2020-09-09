class AddAttachedToEsodInternalLetter < ActiveRecord::Migration
  def change
    add_reference :esod_internal_letters, :document, foreign_key: false
  end
end

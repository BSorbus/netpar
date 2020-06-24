class CreateEsodOutgoingLetterDocument < ActiveRecord::Migration
  def change
    create_table :esod_outgoing_letters_documents do |t|
      t.references :esod_outgoing_letter, index: false, foreign_key: false
      t.references :document, index: false, foreign_key: false

      t.timestamps null: false
    end
    add_index :esod_outgoing_letters_documents, [:esod_outgoing_letter_id, :document_id], unique: true, name: "esod_outgoing_letters_documents_uniq"
  end
end

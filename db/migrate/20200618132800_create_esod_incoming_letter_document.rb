class CreateEsodIncomingLetterDocument < ActiveRecord::Migration
  def change
    #create_table :esod_incoming_letters_matters, id: false do |t|
    create_table :esod_incoming_letters_documents do |t|
      t.references :esod_incoming_letter, index: false, foreign_key: false
      t.references :document, index: false, foreign_key: false

      t.timestamps null: false
    end
    add_index :esod_incoming_letters_documents, [:esod_incoming_letter_id, :document_id], unique: true, name: "esod_incoming_letters_documents_uniq"
  end
end

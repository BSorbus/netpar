class CreateEsodIncomingLetterEsodMatter < ActiveRecord::Migration
  def change
    #create_table :esod_incoming_letters_matters, id: false do |t|
    create_table :esod_incoming_letters_matters do |t|
      #t.integer :esod_incoming_letter_id
      #t.integer :esod_matter_id
      t.references :esod_incoming_letter, index: true, foreign_key: true
      t.references :esod_matter, index: true, foreign_key: true
      t.integer :sprawa
      t.integer :dokument
      t.string :sygnatura
    end
    add_index :esod_incoming_letters_matters, [:esod_matter_id, :esod_incoming_letter_id], unique: true, name: "esod_incoming_letters_matters_matter_incoming_letter"
    add_index :esod_incoming_letters_matters, [:esod_incoming_letter_id, :esod_matter_id], unique: true, name: "esod_incoming_letters_matters_incoming_letter_matter"
    add_index :esod_incoming_letters_matters, [:sygnatura], unique: true, name: "esod_incoming_letters_matters_sygnatura"
  end
end

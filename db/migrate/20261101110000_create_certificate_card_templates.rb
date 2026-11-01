# Wzory kart plastikowych świadectw (HID FARGO HDP6600) – dla rodzaju świadectwa, wersjonowane w czasie jak stawki opłat:
# świadectwo drukuje się wg wzoru obowiązującego w dniu jego wydania. Awers i rewers – Refile (pliki w refile_attachments).
class CreateCertificateCardTemplates < ActiveRecord::Migration
  def change
    create_table :certificate_card_templates do |t|
      t.integer :division_id, null: false
      t.string  :name, null: false
      t.date    :valid_from, null: false
      t.date    :valid_to
      %w(card_front card_back).each do |name|
        t.string  "#{name}_id"
        t.string  "#{name}_filename"
        t.string  "#{name}_content_type"
        t.integer "#{name}_size"
      end
      t.integer :user_id
      t.timestamps null: false
    end
    add_index :certificate_card_templates, [:division_id, :valid_from], unique: true
  end
end

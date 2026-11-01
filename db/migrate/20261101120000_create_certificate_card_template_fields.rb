# Układ nadruku na karcie plastikowej – dla wzoru karty (wersjonowany razem z grafiką): atrybut świadectwa, strona,
# obszar w mm od lewego górnego rogu karty (85,6 × 54 mm) i czcionka. Typ świadectwa – tekst rodzaju do nadruku na karcie.
class CreateCertificateCardTemplateFields < ActiveRecord::Migration
  def change
    create_table :certificate_card_template_fields do |t|
      t.integer :certificate_card_template_id, null: false
      t.string  :attribute_name, null: false
      t.string  :side, null: false, default: 'front'
      t.decimal :x, precision: 6, scale: 2, null: false
      t.decimal :y, precision: 6, scale: 2, null: false
      t.decimal :width, precision: 6, scale: 2, null: false
      t.decimal :height, precision: 6, scale: 2, null: false
      t.decimal :font_size, precision: 4, scale: 1, null: false, default: 10
      t.boolean :bold, null: false, default: false
      t.string  :align, null: false, default: 'left'
      t.string  :color, null: false, default: '000000'
      t.timestamps null: false
    end
    add_index :certificate_card_template_fields, [:certificate_card_template_id, :attribute_name], unique: true,
              name: 'index_card_template_fields_on_template_and_attribute'

    add_column :divisions, :card_print_text, :string
  end
end

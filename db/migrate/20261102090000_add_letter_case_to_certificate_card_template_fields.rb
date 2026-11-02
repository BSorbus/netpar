# Wielkość liter tekstu na karcie plastikowej – dla pola układu nadruku: oryginał, WIELKIE, małe, Pierwsza Wielka (każde słowo).
class AddLetterCaseToCertificateCardTemplateFields < ActiveRecord::Migration
  def change
    add_column :certificate_card_template_fields, :letter_case, :string, null: false, default: 'original'
  end
end

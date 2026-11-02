require 'set'

# Kod weryfikacji świadectwa (QR karty plastikowej: <confirmation>/qrc/<kod>): losowy, 16 znaków, unikalny.
# Nowe świadectwa dostają kod przy zapisie (Certificate before_create); istniejące – tutaj, jednorazowo.
# Generator zapisany w migracji (nie z modelu), żeby migracja działała tak samo niezależnie od późniejszych zmian modelu.
class AddVerificationCodeToCertificates < ActiveRecord::Migration
  ALPHABET = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'.chars.freeze # bez I, L, O, U
  LENGTH = 16

  def up
    add_column :certificates, :verification_code, :string, limit: 16
    add_index :certificates, :verification_code, unique: true

    say_with_time 'Kody weryfikacji dla istniejących świadectw' do
      ids = select_values('SELECT id FROM certificates WHERE verification_code IS NULL ORDER BY id').map(&:to_i)
      used = Set.new
      ids.each_slice(1000) do |slice|
        values = slice.map do |id|
          code = nil
          code = Array.new(LENGTH) { ALPHABET[SecureRandom.random_number(ALPHABET.size)] }.join until code && used.add?(code)
          "(#{id}, '#{code}')"
        end
        # connection.execute – bez wypisywania zapytań: kody to klucze dostępu, nie mogą trafić do logu wdrożenia
        connection.execute "UPDATE certificates AS c SET verification_code = v.code FROM (VALUES #{values.join(', ')}) AS v(id, code) WHERE c.id = v.id"
      end
      ids.size
    end
  end

  def down
    remove_index :certificates, :verification_code
    remove_column :certificates, :verification_code
  end
end

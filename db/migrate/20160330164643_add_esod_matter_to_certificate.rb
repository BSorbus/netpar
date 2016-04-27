class AddEsodMatterToCertificate < ActiveRecord::Migration
  def change
    add_reference :certificates, :esod_matter, index: true, foreign_key: true
  end
end

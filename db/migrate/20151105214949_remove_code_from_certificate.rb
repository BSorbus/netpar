class RemoveCodeFromCertificate < ActiveRecord::Migration
  def change
    remove_column :certificates, :code, :string
  end
end

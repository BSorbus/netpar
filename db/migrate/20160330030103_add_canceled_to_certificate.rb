class AddCanceledToCertificate < ActiveRecord::Migration
  def change
    add_column :certificates, :canceled, :boolean, default: false
  end
end

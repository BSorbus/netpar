class AddCodeToCertificate < ActiveRecord::Migration
  def change
    add_column :certificates, :code, :integer
  end
end

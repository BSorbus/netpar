class AddExtendAttributeToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :family_name, :string,  default: ""
    add_column :proposals, :citizenship_code, :string,  default: ""
  end
end

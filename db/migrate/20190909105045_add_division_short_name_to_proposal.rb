class AddDivisionShortNameToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :division_short_name, :string
  end
end

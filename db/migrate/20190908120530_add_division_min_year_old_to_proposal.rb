class AddDivisionMinYearOldToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :division_min_years_old, :integer
  end
end

class AddTestUnlockedToProposal < ActiveRecord::Migration
  def change
    # add_column :proposals, :test_unlocked, :boolean, null: false, default: false
    add_column :proposals, :test_unlocked, :boolean
  end
end

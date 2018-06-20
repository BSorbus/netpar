class AddForSupplementaryToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :for_supplementary, :boolean, null: false, default: false
  end
end

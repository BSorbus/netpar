class RemoveForSupplementaryFromSubject < ActiveRecord::Migration
  def change
    remove_column :subjects, :for_supplementary, :boolean
  end
end

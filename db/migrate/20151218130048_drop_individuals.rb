class DropIndividuals < ActiveRecord::Migration
  def change
    drop_table :individuals
  end
end

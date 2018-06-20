class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.references :trackable, polymorphic: true, index: true
      t.string :trackable_url
      t.references :user, index: true
      t.string :action
      t.text :parameters

      t.timestamps null: false
    end
  end
end


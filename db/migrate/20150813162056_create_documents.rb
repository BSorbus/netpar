class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :fileattach_id
      t.string :fileattach_filename
      t.string :fileattach_content_type
      t.integer :fileattach_size
      t.references :documentable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end

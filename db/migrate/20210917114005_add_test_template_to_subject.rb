class AddTestTemplateToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :test_template, :string, default: ""
  end
end

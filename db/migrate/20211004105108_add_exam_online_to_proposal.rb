class AddExamOnlineToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :exam_online, :boolean, null: false, default: false
  end
end

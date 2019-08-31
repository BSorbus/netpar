class AddNotApprovedCommentToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :not_approved_comment, :text
  end
end

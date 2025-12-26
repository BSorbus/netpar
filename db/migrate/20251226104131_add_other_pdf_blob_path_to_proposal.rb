class AddOtherPdfBlobPathToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :other_pdf_blob_path, :text
  end
end

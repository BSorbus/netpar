class AddUrlsToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :face_image_blob_url, :text
    add_column :proposals, :bank_pdf_blob_url, :text
  end
end

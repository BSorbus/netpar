class AddConsentPdfBlobPathToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :consent_pdf_blob_path, :text
  end
end

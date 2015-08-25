class AddCertificateToExamination < ActiveRecord::Migration
  def change
    add_reference :examinations, :certificate, index: true, foreign_key: true
  end
end

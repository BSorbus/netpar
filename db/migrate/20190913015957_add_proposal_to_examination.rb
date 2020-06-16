class AddProposalToExamination < ActiveRecord::Migration
  def change
    add_reference :examinations, :proposal, index: true, foreign_key: true
  end
end

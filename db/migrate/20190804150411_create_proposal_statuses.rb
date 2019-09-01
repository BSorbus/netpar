class CreateProposalStatuses < ActiveRecord::Migration
  def change
    create_table :proposal_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
	#  PROPOSAL_STATUS_CREATED = 1
	#  PROPOSAL_STATUS_APPROVED = 2
	#  PROPOSAL_STATUS_NOT_APPROVED = 3
	#  PROPOSAL_STATUS_CLOSED = 4

    proposal_status1 = ProposalStatus.create(name: "Nowe")
    proposal_status2 = ProposalStatus.create(name: "Zaakceptowane")
    proposal_status3 = ProposalStatus.create(name: "Odrzucone")
    proposal_status4 = ProposalStatus.create(name: "Zamknięte")
  end
end

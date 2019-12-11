class AppendToProposalStatus < ActiveRecord::Migration
  def up
    # PROPOSAL_STATUS_CREATED = 1
    ProposalStatus.find_or_create_by!(name: "Nowe") 

    # PROPOSAL_STATUS_APPROVED = 2
    ProposalStatus.find_or_create_by!(name: "Zaakceptowane") 

    # PROPOSAL_STATUS_NOT_APPROVED = 3
    ProposalStatus.find_or_create_by!(name: "Odrzucone") 

    # PROPOSAL_STATUS_CLOSED = 4
    ProposalStatus.find_or_create_by!(name: "Zamknięte") 

    # PROPOSAL_STATUS_ANNULLED = 5
    ProposalStatus.find_or_create_by!(name: "Anulowane") 


    # PROPOSAL_STATUS_EXAMINATION_RESULT_B = 6
    ProposalStatus.find_or_create_by!(name: "Negatywny bez prawa do poprawki") 

    # PROPOSAL_STATUS_EXAMINATION_RESULT_N = 7
    ProposalStatus.find_or_create_by!(name: "Negatywny z prawem do poprawki") 

    # PROPOSAL_STATUS_EXAMINATION_RESULT_O = 8
    ProposalStatus.find_or_create_by!(name: "Nieobecny") 

    # PROPOSAL_STATUS_EXAMINATION_RESULT_P = 7
    ProposalStatus.find_or_create_by!(name: "Pozytywny") 

    # PROPOSAL_STATUS_EXAMINATION_RESULT_Z = 7
    ProposalStatus.find_or_create_by!(name: "Zmiana terminu") 

  end

  def down
    #raise ActiveRecord::IrreversibleMigration
  end
end

class AddEsodContractorToCustomer < ActiveRecord::Migration
  def change
    add_reference :customers, :esod_contractor, index: true, foreign_key: true
  end
end

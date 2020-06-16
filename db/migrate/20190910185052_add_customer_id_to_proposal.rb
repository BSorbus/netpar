class AddCustomerIdToProposal < ActiveRecord::Migration
  def change
    add_reference :proposals, :customer, index: true
  end
end

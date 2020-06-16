class ChangeFieldsTypeInConfirmationLog < ActiveRecord::Migration
  def change
  	change_column :confirmation_logs, :request_json, :text
  	change_column :confirmation_logs, :response_json, :text
  end
end

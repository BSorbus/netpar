class CreateConfirmationLogs < ActiveRecord::Migration
  def change
    create_table :confirmation_logs do |t|
      t.string :remote_ip
      t.string :request_json
      t.string :response_json

      t.timestamps null: false
    end
  end
end

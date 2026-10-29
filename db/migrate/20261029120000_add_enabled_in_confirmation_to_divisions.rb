class AddEnabledInConfirmationToDivisions < ActiveRecord::Migration

  # Rodzaje świadectw, które można weryfikować w aplikacji Confirmation (na start wszystkie morskie).
  def up
    add_column :divisions, :enabled_in_confirmation, :boolean, default: false, null: false

    Division.reset_column_information
    Division.where(category: 'M').update_all(enabled_in_confirmation: true)
  end

  def down
    remove_column :divisions, :enabled_in_confirmation
  end
end

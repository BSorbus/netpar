# Role dla wzorów kart plastikowych świadectw (czynności certificate_card_template:*) – zakładane bez użytkowników;
# administrator przypisuje je w ekranie ról. find_or_create_by! – ponowne uruchomienie nic nie zmienia.
class CreateCertificateCardTemplateRoles < ActiveRecord::Migration
  def up
    CreateRoleService.new.certificate_card_template_manager
    CreateRoleService.new.certificate_card_template_observer
  end

  def down
    Role.where(name: ["Menadżer Wzorów Kart Świadectw", "Obserwator Wzorów Kart Świadectw"]).each do |role|
      role.users.clear if role.respond_to?(:users)
      role.destroy
    end
  end
end

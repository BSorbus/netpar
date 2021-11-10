class AddPolicyDivision < ActiveRecord::Migration

  def up
	role = CreateRoleService.new.division_manager
	puts 'CREATED ROLE: ' << role.name

	role = CreateRoleService.new.division_observer
	puts 'CREATED ROLE: ' << role.name

  end

  def down
  	role = Role.find_by(name: "Menadżer Typów Świadectw")
  	role.destroy if role.present?

  	role = Role.find_by(name: "Obserwator Typów Świadectw")
  	role.destroy if role.present?

  end

end

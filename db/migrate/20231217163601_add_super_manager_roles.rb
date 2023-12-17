class AddSuperManagerRoles < ActiveRecord::Migration
  def up
    role = CreateRoleService.new.exam_l_super_manager
    puts 'CREATED ROLE: ' << role.name

    role = CreateRoleService.new.exam_m_super_manager
    puts 'CREATED ROLE: ' << role.name

    role = CreateRoleService.new.exam_r_super_manager
    puts 'CREATED ROLE: ' << role.name
  end

  def down  
  end

end

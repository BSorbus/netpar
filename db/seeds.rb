
user = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << user.email


role = CreateRoleService.new.work_observer
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"


role = CreateRoleService.new.role_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"


role = CreateRoleService.new.user_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"


role = CreateRoleService.new.department_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"


role = CreateRoleService.new.customer_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"


role = CreateRoleService.new.certificate_l_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"

role = CreateRoleService.new.certificate_m_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"

role = CreateRoleService.new.certificate_r_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"



role = CreateRoleService.new.exam_l_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"

role = CreateRoleService.new.exam_m_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"

role = CreateRoleService.new.exam_r_manager
puts 'CREATED ROLE: ' << role.name
user.roles << role
puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"


role = CreateRoleService.new.role_observer
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.user_observer
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.department_observer
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.customer_observer
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.certificate_l_observer
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.certificate_m_observer
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.certificate_r_observer
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.exam_l_observer
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.exam_m_observer
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.exam_r_observer
puts 'CREATED ROLE: ' << role.name


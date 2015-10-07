class CreateRoleService
  # roles
  def work_observer
    role = Role.find_or_create_by!(name: "Obserwator Działań") do |role|
      role.activities += %w(all:work role:work user:work department:work customer:work exam_l:work exam_m:work exam_r:work certificate_l:work certificate_m:work certificate_r:work license:work)
      role.save!
    end
  end


  def role_manager
    role = Role.find_or_create_by!(name: "Menadżer Ról") do |role|
      role.activities += %w(role:index role:show role:create role:update role:delete role:add_remove_user role:work)
      role.save!
    end
  end
  def role_observer
    role = Role.find_or_create_by!(name: "Obserwator Ról") do |role|
      role.activities += %w(role:index role:show)
      role.save!
    end
  end

  # users
  def user_manager
    role = Role.find_or_create_by!(name: "Menadżer Użytkowników") do |role|
      role.activities += %w(user:index user:show user:create user:update user:delete user:add_remove_role user:work)
      role.save!
    end
  end
  def user_observer
    role = Role.find_or_create_by!(name: "Obserwator Użytkowników") do |role|
      role.activities += %w(user:index user:show)
      role.save!
    end
  end

  # departments
  def department_manager
    role = Role.find_or_create_by!(name: "Menadżer Oddziałów") do |role|
      role.activities += %w(department:index department:show department:create department:update department:delete department:work)
      role.save!
    end
  end
  def department_observer
    role = Role.find_or_create_by!(name: "Obserwator Oddziałów") do |role|
      role.activities += %w(department:index department:show)
      role.save!
    end
  end

  # customers
  def customer_manager
    role = Role.find_or_create_by!(name: "Menadżer Klientów") do |role|
      role.activities += %w(customer:index customer:show customer:create customer:update customer:delete customer:merge customer:work)
      role.save!
    end
  end
  def customer_observer
    role = Role.find_or_create_by!(name: "Obserwator Klientów") do |role|
      role.activities += %w(customer:index customer:show)
      role.save!
    end
  end

  # exam_l
  def exam_l_manager
    role = Role.find_or_create_by!(name: "Menadżer Sesji Egzaminacyjnych Świadectw Lotniczych") do |role|
      role.activities += %w(exam_l:index exam_l:show exam_l:create exam_l:update exam_l:delete exam_l:print exam_l:work)
      role.save!
    end
  end
  def exam_l_observer
    role = Role.find_or_create_by!(name: "Obserwator Sesji Egzaminacyjnych Świadectw Lotniczych") do |role|
      role.activities += %w(exam_l:index exam_l:show)
      role.save!
    end
  end

  # exam_m
  def exam_m_manager
    role = Role.find_or_create_by!(name: "Menadżer Sesji Egzaminacyjnych Świadectw Morskich") do |role|
      role.activities += %w(exam_m:index exam_m:show exam_m:create exam_m:update exam_m:delete exam_m:print exam_m:work)
      role.save!
    end
  end
  def exam_m_observer
    role = Role.find_or_create_by!(name: "Obserwator Sesji Egzaminacyjnych Świadectw Morskich") do |role|
      role.activities += %w(exam_m:index exam_m:show)
      role.save!
    end
  end

  # exam_r
  def exam_r_manager
    role = Role.find_or_create_by!(name: "Menadżer Sesji Egzaminacyjnych Świadectw Radioamtorskich") do |role|
      role.activities += %w(exam_r:index exam_r:show exam_r:create exam_r:update exam_r:delete exam_r:print exam_r:work)
      role.save!
    end
  end
  def exam_r_observer
    role = Role.find_or_create_by!(name: "Obserwator Sesji Egzaminacyjnych Świadectw Radioamtorskich") do |role|
      role.activities += %w(exam_r:index exam_r:show)
      role.save!
    end
  end

  # certificate_l
  def certificate_l_manager
    role = Role.find_or_create_by!(name: "Menadżer Świadectw Lotniczych") do |role|
      role.activities += %w(certificate_l:index certificate_l:show certificate_l:create certificate_l:update certificate_l:delete certificate_l:print certificate_l:work)
      role.save!
    end
  end
  def certificate_l_observer
    role = Role.find_or_create_by!(name: "Obserwator Świadectw Lotniczych") do |role|
      role.activities += %w(certificate_l:index certificate_l:show)
      role.save!
    end
  end

  # certificate_m
  def certificate_m_manager
    role = Role.find_or_create_by!(name: "Menadżer Świadectw Morskich") do |role|
      role.activities += %w(certificate_m:index certificate_m:show certificate_m:create certificate_m:update certificate_m:delete certificate_m:print certificate_m:work)
      role.save!
    end
  end
  def certificate_m_observer
    role = Role.find_or_create_by!(name: "Obserwator Świadectw Morskich") do |role|
      role.activities += %w(certificate_m:index certificate_m:show)
      role.save!
    end
  end

  # certificate_r
  def certificate_r_manager
    role = Role.find_or_create_by!(name: "Menadżer Świadectw Radioamtorskich") do |role|
      role.activities += %w(certificate_r:index certificate_r:show certificate_r:create certificate_r:update certificate_r:delete certificate_r:print certificate_r:work)
      role.save!
    end
  end
  def certificate_r_observer
    role = Role.find_or_create_by!(name: "Obserwator Świadectw Radioamtorskich") do |role|
      role.activities += %w(certificate_r:index certificate_r:show)
      role.save!
    end
  end

  # license
  def license_manager
    role = Role.find_or_create_by!(name: "Menadżer Pozwoleń") do |role|
      role.activities += %w(license:index license:show license:create license:update license:delete license:print license:work)
      role.save!
    end
  end
  def license_observer
    role = Role.find_or_create_by!(name: "Obserwator Pozwoleń") do |role|
      role.activities += %w(license:index license:show)
      role.save!
    end
  end

end

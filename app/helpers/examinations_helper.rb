module ExaminationsHelper

  def examination_policy_check(examination, category_service, action)
    unless ['l', 'm', 'r'].include?(category_service)
       raise "Ruby injection"
    end
    unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'print', 'work'].include?(action)
       raise "Ruby injection"
    end
    return policy(examination).send("#{action}_#{category_service}?")
  end

end
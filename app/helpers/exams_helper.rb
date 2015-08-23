module ExamsHelper

  def exam_policy_check(exam, category_service, action)
    unless ['l', 'm', 'r'].include?(category_service)
       raise "Ruby injection"
    end
    unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'print'].include?(action)
       raise "Ruby injection"
    end
    return policy(exam).send("#{action}_#{category_service}?")
  end

end
module ProposalsHelper

  def proposal_policy_check(proposal, category_service, action)
    unless ['l', 'm', 'r'].include?(category_service)
       raise "Ruby injection"
    end
    unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'print', 'work'].include?(action)
       raise "Ruby injection"
    end
    return policy(proposal).send("#{action}_#{category_service}?")
  end

end
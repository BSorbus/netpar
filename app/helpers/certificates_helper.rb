module CertificatesHelper

  #  <% if policy(@certificate).show_l? %>
  #  <% if policy(@certificate).show_l? %>
  #  <% if policy(@certificate).show_l? %>
  #  lub 
  #  <% if policy(:certificate).new_l? %>
  #  <% if policy(:certificate).new_l? %>
  #  <% if policy(:certificate).new_l? %>
  #  itd...

  def certificate_policy_check(certificate, category_service, action)
    unless ['l', 'm', 'r'].include?(category_service)
       raise "Ruby injection"
    end
    unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'print', 'work'].include?(action)
       raise "Ruby injection"
    end
    return policy(certificate).send("#{action}_#{category_service}?")
  end

end
class UserRolesDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :attachment_url, :image_tag, :get_fileattach_as_small_image, :policy

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Roleple: 'certificates.email'
    @sortable_columns ||= %w( 
                              Role.name
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    @searchable_columns ||= %w(
                              Role.name 
                            )
  end

  private

  def data
    # comma separated list of the values for each cell of a table row
    records.map do |record|
      user_has_role = User.joins(:roles).where(roles: {id: record.id}, users: {id: options[:only_for_current_user_id]}).any?
      [
        record.id,
        # record.name,
        link_to(record.name, @view.role_path(record)),
        user_has_role ? '<div style="text-align: center"><div class="glyphicon glyphicon-ok"></div></div>' : '',
        user_has_role ? "<button ajax-path='" + @view.role_user_path(role_id: record.id, id: options[:only_for_current_user_id]) + "' ajax-method='DELETE' class='button-xs-danger glyphicon glyphicon-minus' ></button>"
                      : "<button ajax-path='" + @view.role_users_path(role_id: record.id, id: options[:only_for_current_user_id]) + "' ajax-method='POST' class='button-xs-success fa fa-plus' ></button>"
      ]
    end
  end

  def get_raw_records
    #Role.joins(:division, :customer, :exam).where(exam_id: options[:only_for_current_user_id]).includes(:division, :customer, :exam).references(:division, :customer, :exam).all
    Role.all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end

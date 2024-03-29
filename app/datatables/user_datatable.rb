class UserDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'users.email'
    @sortable_columns ||= %w( 
                              User.name 
                              User.email
                              Department.short  
                              User.current_sign_in_ip
                              User.current_sign_in_at
                              User.last_activity_at
                              User.password_changed_at
                              User.deleted_at
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'users.email'
    @searchable_columns ||= %w(
                              User.name 
                              User.email 
                              Department.short  
                              User.current_sign_in_ip
                              User.current_sign_in_at
                              User.last_activity_at
                              User.password_changed_at
                              User.deleted_at
                            )
  end

  private

  def data
    # comma separated list of the values for each cell of a table row
    # example: record.attribute,
    records.map do |record|
      [
        record.id,
        record.name.present? ? link_to(record.name, @view.user_path(record)) : '',
        link_to(record.email, @view.user_path(record)),
        record.department.present? ? link_to(record.department.short, @view.department_path(record.department)) : '',
        record.current_sign_in_ip,
        record.current_sign_in_at.present? ? record.current_sign_in_at.strftime("%Y-%m-%d %H:%M:%S") : '' ,
        record.last_activity_at.present? ? record.last_activity_at.strftime("%Y-%m-%d %H:%M:%S") : '' ,
        record.password_changed_at.present? ? record.password_changed_at.strftime("%Y-%m-%d %H:%M:%S") : '' ,
        record.deleted_at.present? ? record.deleted_at.strftime("%Y-%m-%d %H:%M:%S") : '' 
      ]
    end
  end

  def get_raw_records
    #User.joins(:department).by_name.all
    User.includes(:department).references(:department).all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end

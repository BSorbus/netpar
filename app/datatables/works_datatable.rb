class WorksDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :t

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Certificateple: 'certificates.email'
    @sortable_columns ||= %w( 
                              Work.created_at
                              User.name
                              Work.action
                              Work.trackable_type
                              Work.trackable_id
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Certificateple: 'certificates.email'
    @searchable_columns ||= %w(
                              Work.created_at
                              User.name
                              User.email
                              Work.action
                              Work.trackable_type
                              Work.trackable_id
                              Work.parameters
                            )
  end

  private

  def data
    # comma separated list of the values for each cell of a table row
    # certificateple: record.attribute,

    records.map do |record|

      [
        record.id,
        record.created_at.strftime("%Y-%m-%d %H:%M:%S"),
        record.user ? link_to( record.user.fullname, record.user ) : record.user_id,
        record.action,
        record.trackable_type,
        # nazwy obiektow po polsku
        #record.trackable_type.present? ? t("activerecord.models.#{record.trackable_type.downcase}") : '',
        record.trackable ? link_to( record.trackable.fullname_and_id, record.trackable_url ) : record.trackable_id,
        #display_my_hash(record.parameters)
        record.parameters
      ]
    end
  end

  def get_raw_records
    #Certificate.joins(:division, :customer, :exam).where(exam_id: options[:only_for_current_exam_id]).includes(:division, :customer, :exam).references(:division, :customer, :exam).all
    #Work.where(owner_id: options[:only_for_current_user_id], owner_type: 'User').all
    #Work.where(owner_id: options[:only_for_current_user_id], owner: {source_type: 'User'}).includes(:owner).all

    if (options[:trackable_id]).present? && (options[:trackable_type]).present?
      Work.where(trackable_id: options[:trackable_id], trackable_type: options[:trackable_type]).includes(:user).references(:user).all
    elsif (options[:only_for_current_user_id]).present?
      Work.where(user_id: options[:only_for_current_user_id]).includes(:user).references(:user).all
    else
      Work.includes(:user).references(:user).all
    end


  end

  # ==== Insert 'presenter'-like methods below if necessary
  def display_my_hash(my_hash)
#    str = ''
#    eval(my_hash).each do |key,value|
#      str += "#{key} = #{value}" + "\n"
#    end
#    eval(my_hash).map 
  end

end

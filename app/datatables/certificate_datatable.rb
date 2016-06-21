class CertificateDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :attachment_url, :image_tag, :get_fileattach_as_small_image, :policy

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Certificateple: 'certificates.email'

#                              Esod::Matter.znak 
    @sortable_columns ||= %w( 
                              Certificate.number
                              Certificate.date_of_issue
                              Certificate.valid_thru
                              Division.name
                              Customer.name
                              Exam.number
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Certificateple: 'certificates.email'
    @searchable_columns ||= %w(
                              Certificate.number 
                              Customer.name
                              Customer.given_names
                              Exam.number
                              Customer.address_city
                              Division.name 
                              Certificate.date_of_issue 
                            )
  end

  private

  def data
    # comma separated list of the values for each cell of a table row
    # certificateple: record.attribute,
    show_customer = policy(:customer).show?

    records.map do |record|
 
      attach = record.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).last 

      [
        record.id,
        attach.present? ? link_to( image_tag( get_fileattach_as_small_image(attach, record.category.downcase) ), @view.certificate_path(params[:category_service], record)) : '',
        #record.esod_matter.present? ? link_to(record.esod_matter.znak, @view.esod_matter_path(record.esod_matter)) : '',
        record.esod_matters.any? ? record.esod_matters.flat_map {|row| row.znak_with_padlock }.join(', ') : "",
        link_to(record.number, @view.certificate_path(record.category.downcase, record)),
        record.date_of_issue,
        record.valid_thru,
        record.division.name,
        show_customer ? link_to(record.customer.fullname_and_address, @view.customer_path(record.customer)) : 'xxx-xxx',
        link_to(record.exam.fullname, @view.exam_path(record.category.downcase, record.exam)),
        record.category 
      ]
    end
  end

  def get_raw_records
    #case options[:category_scope]
    case params[:category_service]
    when 'l'
      #Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam, :esod_matter).references(:division, :customer, :exam, :esod_matter).only_category_l.all #
      Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam).references(:division, :customer, :exam).only_category_l.all #
    when 'm'
      #Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam, :esod_matter).references(:division, :customer, :exam, :esod_matter).only_category_m.all #
      Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam).references(:division, :customer, :exam).only_category_m.all #
    when 'r'
      #Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam, :esod_matter).references(:division, :customer, :exam, :esod_matter).only_category_r.all #
      Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam).references(:division, :customer, :exam).only_category_r.all #
    else
      #Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam, :esod_matter).references(:division, :customer, :exam, :esod_matter).all #
      Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam).references(:division, :customer, :exam).all #
    end  
  end

  # ==== Insert 'presenter'-like methods below if necessary
end


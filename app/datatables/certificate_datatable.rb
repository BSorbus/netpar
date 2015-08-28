class CertificateDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :attachment_url

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Certificateple: 'certificates.email'
    @sortable_columns ||= %w( 
                              Certificate.number
                              Certificate.date_of_issue
                              Certificate.valid_thru
                              Certificate.certificate_status
                              Division.name
                              Customer.name
                              Exam.number
                              Certificate.category 
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
    records.map do |record|
      [
        record.id,
        #'<img src="' +  '/attachments/store/fill/87/61/87556/BOGUSZEWSKI+ROBERT_OR_L-16646.jpg" alt="Boguszewski+robert or l 16646' +  '">',
        #record.document_image_id? ? '<img src="' + get_attach_path(record)+ '">' : ' ',
        # OK
        #record.document_image_id? ? '<a href="/' + record.category.downcase + '/certificates/' + record.id.to_s + '"><img src="' + get_attach_path(record) + '"></a>' : ' ',
        record.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).any? ? '<a href="/' + record.category.downcase + '/certificates/' + record.id.to_s + '"><img src="' + get_attach_path(record)+ '"></a>' : ' ',
        link_to(record.number, @view.certificate_path(record.category.downcase, record)),
        record.date_of_issue,
        record.valid_thru,
        record.certificate_status,
        record.division.name,
        link_to(record.customer.fullname_and_address, @view.customer_path(record.customer)),
        link_to(record.exam.fullname, @view.exam_path(record.category.downcase, record.exam)),
        record.category 
      ]
    end
  end

  def get_attach_path(record)
    case record.category.downcase
    when 'l'
      attachment_url(record.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).last, :fileattach, :fill, 87, 61, format: 'jpg')
    when 'm'
      attachment_url(record.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).last, :fileattach, :fill, 54, 77, format: 'jpg')
    when 'r'
      attachment_url(record.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).last, :fileattach, :fill, 54, 77, format: 'jpg')
    end  
  end

  def get_raw_records
    #case options[:category_scope]
    case params[:category_service]
    when 'l'
      Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam).references(:division, :customer, :exam).only_category_l.all #
    when 'm'
      Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam).references(:division, :customer, :exam).only_category_m.all #
    when 'r'
      Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam).references(:division, :customer, :exam).only_category_r.all #
    else
      Certificate.joins(:division, :customer, :exam).includes(:division, :customer, :exam).references(:division, :customer, :exam).all #
    end  
  end

  # ==== Insert 'presenter'-like methods below if necessary
end


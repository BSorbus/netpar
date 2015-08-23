class ExamCertificatesDatatable < AjaxDatatablesRails::Base
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
        #record.document_image_id? ? '<img src="' + get_attach_path(record)+ '">' : ' ',
        # OK
        #record.document_image_id? ? '<a href="/' + record.category.downcase + '/certificates/' + record.id.to_s + '"><img src="' + get_attach_path(record)+ '"></a>' : ' ',
        record.documents.where(fileattach_content_type: 'image/jpeg').any? ? '<a href="/' + record.category.downcase + '/certificates/' + record.id.to_s + '"><img src="' + get_attach_path(record)+ '"></a>' : ' ',
        link_to(record.number, @view.certificate_path(params[:category_service], record)),
        record.date_of_issue,
        record.valid_thru,
        record.certificate_status,
        record.division.name,
        link_to(record.customer.fullname_and_address, @view.customer_path(record.customer)),
        link_to(record.exam.fullname, @view.exam_path(params[:category_service], record.exam)),
        record.category 
      ]
    end
  end

  def get_attach_path(record)
    case record.category.downcase
    when 'l'
      attachment_url(record.documents.where(fileattach_content_type: 'image/jpeg').last, :fileattach, :fill, 87, 61, format: 'jpg')
    when 'm'
      attachment_url(record.documents.where(fileattach_content_type: 'image/jpeg').last, :fileattach, :fill, 54, 77, format: 'jpg')
    when 'r'
      attachment_url(record.documents.where(fileattach_content_type: 'image/jpeg').last, :fileattach, :fill, 54, 77, format: 'jpg')
    end  
  end

  def get_raw_records
    Certificate.joins(:division, :customer, :exam).where(exam_id: options[:only_for_current_exam_id]).includes(:division, :customer, :exam).references(:division, :customer, :exam).all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end


class ExamExaminationsDatatable < AjaxDatatablesRails::Base
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
                              Customer.name
                              Examination.examination_category
                              Division.name
                              Examination.examination_resoult
                              Examination.note
                              Examination.category 
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Examinationple: 'certificates.email'
    @searchable_columns ||= %w(
                              Customer.name
                              Customer.given_names
                              Customer.address_city
                              Division.name
                              Examination.note 
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
        record.documents.where(fileattach_content_type: 'image/jpeg').any? ? '<a href="/' + record.category.downcase + '/examinations/' + record.id.to_s + '"><img src="' + get_attach_path(record)+ '"></a>' : ' ',
        link_to(record.customer.fullname_and_address, @view.customer_path(record.customer)),
        record.examination_category_name,
        record.division.name,
        record.examination_resoult_name,
        link_to(record.note, @view.examination_path(params[:category_service], record)),
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
    Examination.joins(:division, :customer, :exam).where(exam_id: options[:only_for_current_exam_id]).includes(:division, :customer, :exam).references(:division, :customer, :exam).all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end


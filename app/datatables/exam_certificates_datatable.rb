class ExamCertificatesDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :attachment_url, :image_tag, :get_fileattach_as_small_image, :policy

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
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Certificateple: 'certificates.email'
    @searchable_columns ||= %w(
                              Certificate.number 
                              Customer.name
                              Customer.given_names
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
        attach.present? ? link_to( image_tag( get_fileattach_as_small_image(attach, record.category.downcase) ), @view.certificate_path(params[:category_service], record, back_url: @view.exam_path(record.exam.category.downcase, record.exam))) : '',
        #record.esod_matter.present? ? link_to(record.esod_matter.znak, @view.esod_matter_path(record.esod_matter)) : '',
        record.esod_matters.any? ? record.esod_matters.flat_map {|row| row.znak }.join(', ') : "",
        link_to(record.number, @view.certificate_path(params[:category_service], record, back_url: @view.exam_path(record.exam.category.downcase, record.exam))),
        record.date_of_issue,
        record.valid_thru,
        record.certificate_status_name,
        record.division.name,
        show_customer ? link_to(record.customer.fullname_and_address, @view.customer_path(record.customer)) : 'xxx-xxx',
        record.category, 
        link_to(' ', @view.certificate_path(params[:category_service], record, back_url: @view.exam_path(record.exam.category.downcase, record.exam)), 
                        class: 'glyphicon glyphicon-eye-open', title: 'Pokaż', rel: 'tooltip') + 
                    " " +
        link_to(' ', @view.certificate_path(params[:category_service], record, back_url: @view.exam_path(record.exam.category.downcase, record.exam)), 
                        method: :delete, 
                        data: { confirm: "Czy na pewno chcesz usunąć ten wpis?" }, 
                        class: "glyphicon glyphicon-trash", title: 'Usuń', rel: 'tooltip')  
      ]
    end
  end

  def get_raw_records
    #Certificate.joins(:division, :customer, :exam).where(exam_id: options[:only_for_current_exam_id]).includes(:division, :customer, :exam, :esod_matter).references(:division, :customer, :exam, :esod_matter).all
    Certificate.joins(:division, :customer, :exam).where(exam_id: options[:only_for_current_exam_id]).includes(:division, :customer, :exam).references(:division, :customer, :exam).all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end


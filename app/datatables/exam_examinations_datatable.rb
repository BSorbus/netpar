class ExamExaminationsDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :attachment_url, :image_tag, :get_fileattach_as_small_image

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Certificateple: 'certificates.email'
    @sortable_columns ||= %w( 
                              Customer.name
                              Examination.examination_category
                              Division.name
                              Examination.examination_resoult
                              Examination.note
                              Certificate.number
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

      attach = record.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).last 

      [
        record.id,
        attach.present? ? link_to( image_tag( get_fileattach_as_small_image(attach, params[:category_service]) ), @view.examination_path(params[:category_service], record, back_url: @view.exam_path(record.exam.category.downcase, record.exam))) : '',
        link_to(record.customer.fullname_and_address, @view.customer_path(record.customer)),
        record.examination_category_name,
        record.division.name + " (" + record.division.short_name + ")",
        record.examination_resoult_name,
        record.note,
        record.certificate.present? ? link_to(record.certificate.number, @view.certificate_path(record.certificate.category.downcase, record.certificate)) : '',
        #record.certificate.present? ? record.certificate.number : '',
        record.category, 
        link_to(' ', @view.examination_path(record.category.downcase, record, back_url: @view.exam_path(record.exam.category.downcase, record.exam)), 
                        class: 'glyphicon glyphicon-eye-open', title: 'Pokaż', rel: 'tooltip') + 
                    " " +
        link_to(' ', @view.examination_path(record.category.downcase, record, back_url: @view.exam_path(record.exam.category.downcase, record.exam)), 
                        method: :delete, 
                        data: { confirm: "Czy na pewno chcesz usunąć ten wpis?" }, 
                        class: "glyphicon glyphicon-trash", title: 'Usuń', rel: 'tooltip')  

      ]
    end
  end

  def get_raw_records
    Examination.joins(:division, :customer, :exam).where(exam_id: options[:only_for_current_exam_id]).includes(:division, :customer, :exam, :certificate).references(:division, :customer, :exam, :certificate).all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end


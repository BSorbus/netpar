class ExamExaminationsDatatable < AjaxDatatablesRails::Base
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
                              Examination.esod_category
                              Division.name
                              Customer.name
                              Examination.examination_result
                              Examination.note
                              Certificate.number
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Examinationple: 'certificates.email'
    @searchable_columns ||= %w(
                              Examination.esod_category 
                              Division.name
                              Customer.name
                              Customer.given_names
                              Customer.address_city
                              Examination.note 
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
        attach.present? ? link_to( image_tag( get_fileattach_as_small_image(attach, params[:category_service]) ), @view.examination_path(params[:category_service], record, back_url: @view.exam_path(record.exam.category.downcase, record.exam))) : '',
#       record.esod_matters.any? ? record.esod_matters.flat_map {|row| row.znak_with_padlock }.join(', ') : "",
        record.esod_matters.any? ? record.esod_matters.flat_map {|row| link_to row.znak_with_padlock, @view.esod_matter_path(row.id) }.join(', ') : "",

        record.esod_category_name,
        record.division.name + " (" + record.division.short_name + ")",
        show_customer ? link_to(record.customer.fullname_and_address, @view.customer_path(record.customer)) : 'xxx-xxx',
        record.examination_result_name,
        record.note,
        record.certificate.present? ? link_to(record.certificate.number, @view.certificate_path(record.certificate.category.downcase, record.certificate)) : '',
        record.category, 
        link_to(' ', @view.examination_path(record.category.downcase, record, back_url: @view.exam_path(record.exam.category.downcase, record.exam)), 
                        class: "fa fa-eye", title: 'Pokaż', rel: 'tooltip') + 
                    " " +
        link_or_icon(record)

      ]
    end
  end

  def get_raw_records
    #Examination.joins(:division, :customer, :exam).where(exam_id: options[:only_for_current_exam_id]).includes(:division, :customer, :exam, :certificate, :esod_matter).references(:division, :customer, :exam, :certificate, :esod_matter).all
    Examination.joins(:division, :customer, :exam).where(exam_id: options[:only_for_current_exam_id]).includes(:division, :customer, :exam, :certificate).references(:division, :customer, :exam, :certificate).all
  end

  def link_or_icon(rec)
    if rec.proposal_id.present?
      link_to(' ', @view.proposal_path(rec.proposal.category.downcase, rec.proposal_id), 
                      class: "fa fa-download", title: 'Pokaż elektroniczne zgłoszenie', rel: 'tooltip')
    else
      link_to(' ', @view.examination_path(rec.category.downcase, rec, back_url: @view.exam_path(rec.exam.category.downcase, rec.exam)), 
                              method: :delete, 
                              data: { confirm: "Czy na pewno chcesz usunąć ten wpis?" }, 
                              class: "fa fa-trash-o text-danger", title: 'Usuń', rel: 'tooltip')
    end
  end

  # ==== Insert 'presenter'-like methods below if necessary
end


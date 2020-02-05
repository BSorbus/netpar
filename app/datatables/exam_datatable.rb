class ExamDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :attachment_url, :image_tag, :get_fileattach_as_small_image

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'exams.email'

    @sortable_columns ||= %w( 
                              Exam.number
                              Exam.date_exam
                              Exam.place_exam
                              Exam.province_name
                              Exam.chairman
                              Exam.secretary
                              Exam.max_examinations
                              Exam.proposals_important_count
                              Exam.examinations_count
                              Exam.certificates_count
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'exams.email'
    @searchable_columns ||= %w(
                              Exam.number
                              Exam.date_exam
                              Exam.place_exam
                              Exam.province_name
                              Exam.chairman
                              Exam.secretary
                              Exam.max_examinations
                              Exam.proposals_important_count
                              Exam.examinations_count
                              Exam.certificates_count
                            )
  end

  private
 
  def data
    # comma separated list of the values for each cell of a table row
    # example: record.attribute,
    records.map do |record|
      attach = record.documents.where(fileattach_content_type: ['image/jpeg', 'image/png', 'application/pdf']).last 
      [
        record.id,
        attach.present? ? link_to( image_tag( get_fileattach_as_small_image(attach, record.category.downcase) ), @view.exam_path(params[:category_service], record)) : '',
#       record.esod_matters.any? ? record.esod_matters.flat_map {|row| row.znak_with_padlock }.join(', ') : "",
        record.esod_matters.any? ? record.esod_matters.flat_map {|row| link_to row.znak_with_padlock, @view.esod_matter_path(row.id) }.join(', ') : "",

        link_to(record.number, @view.exam_path(record.category.downcase, record)),
        record.date_exam,
        record.place_exam,
        record.province_name,
        record.chairman,
        record.secretary,
        display_max_examinations(record.max_examinations),
        display_proposals_important_count(record.proposals_important_count),
        display_examinations_count(record.examinations_count),
        display_certificates_count(record.certificates_count),
        record.category 
      ]
    end
  end

  def get_raw_records
    #case options[:category_scope]
    case params[:category_service]
    when 'l'
      #Exam.includes(:esod_matter).references(:esod_matter).only_category_l.all
      Exam.only_category_l.all
    when 'm'
      #Exam.includes(:esod_matter).references(:esod_matter).only_category_m.all
      Exam.only_category_m.all
    when 'r'
      #Exam.includes(:esod_matter).references(:esod_matter).only_category_r.all
      Exam.only_category_r.all
    else
      #Exam.includes(:esod_matter).references(:esod_matter).all
      Exam.all
    end  
  end

  def display_max_examinations(count)
    count ||= 0
    count > 0 ? '<div style="text-align: center"><span class="badge alert-warning">' + "#{count}" + '</span></div>' : ''
  end

  def display_proposals_important_count(count)
    count ||= 0
    count > 0 ? '<div style="text-align: center"><span class="badge alert-info">' + "#{count}" + '</span></div>' : ''
  end

  def display_examinations_count(count)
    count ||= 0
    count > 0 ? '<div style="text-align: center"><span class="badge alert-info">' + "#{count}" + '</span></div>' : ''
  end

  def display_certificates_count(count)
    count ||= 0
    count > 0 ? '<div style="text-align: center"><span class="badge alert-success">' + "#{count}" + '</span></div>' : ''
  end

end

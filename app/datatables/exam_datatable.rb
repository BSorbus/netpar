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
                              Esod::Matter.znak 
                              Exam.number
                              Exam.date_exam
                              Exam.place_exam
                              Exam.chairman
                              Exam.secretary
                              Exam.examinations_count
                              Exam.certificates_count
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'exams.email'
    @searchable_columns ||= %w(
                              Esod::Matter.znak 
                              Exam.number
                              Exam.date_exam
                              Exam.place_exam
                              Exam.chairman
                              Exam.secretary
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
        record.esod_matter.present? ? link_to(record.esod_matter.znak, @view.esod_matter_path(record.esod_matter)) : '',
        link_to(record.number, @view.exam_path(record.category.downcase, record)),
        record.date_exam,
        record.place_exam,
        record.chairman,
        record.secretary,
        '<div style="text-align: center"><span class="badge alert-info">' + "#{record.examinations_count}" + '</span></div>',
        '<div style="text-align: center"><span class="badge alert-success">' + "#{record.certificates_count}" + '</span></div>',
        record.category 
      ]
    end
  end

  def get_raw_records
    #case options[:category_scope]
    case params[:category_service]
    when 'l'
      Exam.includes(:esod_matter).references(:esod_matter).only_category_l.all
    when 'm'
      Exam.includes(:esod_matter).references(:esod_matter).only_category_m.all
    when 'r'
      Exam.includes(:esod_matter).references(:esod_matter).only_category_r.all
    else
      Exam.includes(:esod_matter).references(:esod_matter).all
    end  
  end

  # ==== Insert 'presenter'-like methods below if necessary
end

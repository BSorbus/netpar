class ExamDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :attachment_url

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'exams.email'
    @sortable_columns ||= %w( 
                              Exam.number
                              Exam.date_exam
                              Exam.place_exam
                              Exam.chairman
                              Exam.secretary
                              Exam.committee_member1
                              Exam.committee_member2
                              Exam.committee_member3
                              Exam.category 
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'exams.email'
    @searchable_columns ||= %w(
                              Exam.number
                              Exam.date_exam
                              Exam.place_exam
                              Exam.chairman
                              Exam.secretary
                              Exam.committee_member1
                              Exam.committee_member2
                              Exam.committee_member3
                              Exam.category 
                            )
  end

  private

  def data
    # comma separated list of the values for each cell of a table row
    # example: record.attribute,
    records.map do |record|
      [
        record.id,
        link_to(record.number, @view.exam_path(record.category.downcase, record)),
        record.date_exam,
        record.place_exam,
        record.chairman,
        record.secretary,
        record.committee_member1,
        record.committee_member2,
        record.committee_member3,
        record.category 
      ]
    end
  end

  def get_raw_records
    #case options[:category_scope]
    case params[:category_service]
    when 'l'
      Exam.only_category_l.all
    when 'm'
      Exam.only_category_m.all
    when 'r'
      Exam.only_category_r.all
    else
      Exam.all
    end  
  end

  # ==== Insert 'presenter'-like methods below if necessary
end

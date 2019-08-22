class ExamProposalsDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :attachment_url, :image_tag, :get_fileattach_as_small_image, :policy

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Proposalple: 'proposals.email'
    @sortable_columns ||= %w( 
                              Proposal.name
                              Proposal.given_names
                              Proposal.pesel
                              Proposal.birth_date
                              Proposal.address_city
                              Division.name
                              ProposalStatus.name
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Proposalple: 'proposals.email'
    @searchable_columns ||= %w(
                              Proposal.name
                              Proposal.given_names
                              Proposal.pesel
                              Proposal.birth_date
                              Proposal.address_city
                              Division.name 
                              ProposalStatus.name 
                            )
  end

  private

  def data

    records.map do |record|
  
      [
        record.id,
        record.name,
        record.given_names,
        record.pesel,
        record.birth_date,
        record.address_city,
        record.division.name,
        record.proposal_status.name,
        record.category, 
        ''
        # link_to(' ', @view.proposal_path(params[:category_service], record, back_url: @view.exam_path(record.exam.category.downcase, record.exam)), 
        #                 class: 'glyphicon glyphicon-eye-open', title: 'Pokaż', rel: 'tooltip')
      ]
    end
  end

  def get_raw_records
    Proposal.joins(:division, :exam, :proposal_status).where(exam_id: options[:only_for_current_exam_id]).includes(:division, :exam, :proposal_status).references(:division, :exam, :proposal_status).all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end


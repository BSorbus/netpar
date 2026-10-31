module ProposalsHelper

  def proposal_policy_check(proposal, category_service, action)
    unless ['l', 'm', 'r'].include?(category_service)
       raise "Ruby injection"
    end
    unless ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy', 'print', 'work', 
            'edit_approved', 'edit_not_approved', 'edit_closed', 'edit_change_exam', 
            'update_approved', 'update_not_approved', 'update_closed', 'update_change_exam',
            'unlock_testportal_tests_access', 'lock_testportal_tests_access'].include?(action)
       raise "Ruby injection"
    end
    return policy(proposal).send("#{action}_#{category_service}?")
  end

  def category_name(data)
    case data.category
    when 'M'
      Proposal::CATEGORY_NAME_M
    when 'R'
      Proposal::CATEGORY_NAME_R
    when ''
      ''
    else
      nil
    end  
  end

  def proposal_no_data
    # data =
    # '<div class="col-sm-12" class="clearfix">
    #   <div class="alert alert-info alert-dismissable">
    #     <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
    #     <h2 class="center">' + t(".no_data") + '</h2>
    #   </div>
    # </div>'
    # data.html_safe

    data =
    '<div>
      <fieldset class="my-fieldset">
        <legend class="my-fieldset">' + t(".no_data") + '</legend>
        <p class="center">' + t(".no_data_comment") + '</p>
      </fieldset>
    </div>'

    data.html_safe
  end

  def proposal_rec_info(data)
    t('proposals.proposal.rec_info', data: "#{data.created_at.strftime('%Y-%m-%d %H:%M:%S')} [#{category_name(data)}][#{data.division.short_name}]")
  end

  def proposal_rec_status_name(data)
    t("proposals.status_id_#{data.proposal_status_id}_name")
  end

  # Panel „Aplikacja Egzaminy”: data z API (ISO 8601) w formacie jak w NETPAR.
  def egzaminy_time(value)
    value.present? ? Time.zone.parse(value.to_s).strftime('%Y-%m-%d %H:%M:%S') : ''
  end

  # Panel „Aplikacja Egzaminy”: szczegóły zdarzenia z historii zgłoszenia (data z API) – czytelnie, z nazwami z NETPAR.
  def egzaminy_event_details(event)
    data = event['data'] || {}
    scope = 'pages.proposal_egzaminy.details'
    parts = []
    case event['kind']
    when 'submitted'
      exam = Exam.find_by(id: data['exam_id'])
      division = Division.find_by(id: data['division_id'])
      parts << "#{t('exam', scope: scope)}: #{exam ? exam.number : data['exam_id']}" if data['exam_id'].present?
      parts << "#{t('division', scope: scope)}: #{division ? division.short_name : data['division_id']}" if data['division_id'].present?
    when 'mail'
      template = t(data['template'].to_s, scope: 'pages.proposal_egzaminy.mail_templates', default: data['template'].to_s)
      parts << "#{t('to', scope: scope)}: #{data['to']}" if data['to'].present?
      parts << "#{t('mail', scope: scope)}: #{template}" if data['template'].present?
    when 'netpar_update'
      data.each do |key, value|
        case key
        when 'proposal_status_id'
          status = ProposalStatus.find_by(id: value)
          parts << "#{t('status', scope: scope)}: #{status ? status.name : value}"
        when 'not_approved_comment'
          parts << "#{t('comment', scope: scope)}: #{value}" if value.present?
        when 'exam_fullname'
          parts << "#{t('exam', scope: scope)}: #{value}"
        when 'exam_date_exam'
          parts << "#{t('exam_date', scope: scope)}: #{value}"
        when 'test_unlocked'
          parts << "#{t('test_unlocked', scope: scope)}: #{value ? t('pages.proposal_egzaminy.yes_label') : '–'}"
        when 'exam_id'
          next # sesja – w exam_fullname
        else
          parts << "#{key}: #{value}"
        end
      end
    end
    parts.join('; ')
  end

end

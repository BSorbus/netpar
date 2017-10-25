class ChartsController < ApplicationController
  before_action :authenticate_user!

  # Events for showed user
  def by_month_all_certificates
    #render json: Event.group_by_month(:created_at).count #.map { |k, v| [I18n.t("date.month_names")[k], v] }
    render json: Certificate.group_by_month(:created_at, last: 60).count
  end

  def by_month_all_errands
    result1 = Errand.group_by_month(:adoption_date).count
    result2 = Errand.group_by_month(:start_date).count
    result3 = Errand.group_by_month(:end_date).count

    render json: [{name: 'Ilość (wg daty przyjęcia)',   data: result1},
                  {name: 'Ilość (wg daty rozpoczęcia)', data: result2},
                  {name: 'Ilość (wg daty zakończenia)', data: result3}]
  end

  def by_status_type_all_errands
    data_array = []
    EventStatus.all.each do |event_status|
      EventType.all.each do |event_type|  
        data_array << { name: "#{event_status.name}", 
                        data: {"#{event_type.name}": Event.where( event_status_id: [event_status.id], event_type_id: [event_type.id] ).size } }
      end
    end
    render json: data_array
  end


end
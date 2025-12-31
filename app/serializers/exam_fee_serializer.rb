class ExamFeeSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :id, :esod_category, :esod_category_with_name, :price, :valid_from, :valid_to

  # belongs_to :division # w starej wersji AMS nie działa
  has_one :division

  def price
    number_with_precision(object.price, precision: 2, delimiter: ' ', separator: ',')    
  end

  def valid_from
    object.valid_from.present? ? object.valid_from.strftime("%Y-%m-%d") : ''  
  end

  def valid_to
    object.valid_to.present? ? object.valid_to.strftime("%Y-%m-%d") : ''  
  end

end

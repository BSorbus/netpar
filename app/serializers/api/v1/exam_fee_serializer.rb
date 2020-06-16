class Api::V1::ExamFeeSerializer < ActiveModel::Serializer
  attributes :id, :esod_category, :division_id, :price

end

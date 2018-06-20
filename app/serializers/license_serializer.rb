class LicenseSerializer < ActiveModel::Serializer
  attributes :id, :department, :number, :date_of_issue, :valid_to, :call_sign, :category, :transmitter_power, :name_type_station, :emission, :input_frequency, :output_frequency, :operator_1, :operator_2, :operator_3, :applicant_name, :applicant_location, :enduser_name, :enduser_location, :station_location, :type_license
end

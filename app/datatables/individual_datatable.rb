class IndividualDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto, :attachment_url

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Individualple: 'individuals.email'
    @sortable_columns ||= %w( 
                              Individual.number
                              Individual.date_of_issue
                              Individual.valid_thru
                              Individual.license_status
                              Individual.call_sign
                              Individual.category
                              Individual.transmitter_power
                              Certificate.number
                              Customer.name
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Individualple: 'individuals.email'
    @searchable_columns ||= %w(
                              Individual.number
                              Individual.date_of_issue
                              Individual.valid_thru
                              Individual.call_sign
                              Individual.transmitter_power
                              Certificate.number
                              Certificate.date_of_issue
                              Customer.name
                              Customer.given_names
                              Customer.address_city
                            )
  end

  private

  def data
    # comma separated list of the values for each cell of a table row
    # individualple: record.attribute,
    records.map do |record|
      [
        record.id,
        #'<img src="' +  '/attachments/store/fill/87/61/87556/BOGUSZEWSKI+ROBERT_OR_L-16646.jpg" alt="Boguszewski+robert or l 16646' +  '">',
        #record.document_image_id? ? '<img src="' + get_attach_path(record)+ '">' : ' ',
        # OK
        #record.document_image_id? ? '<a href="/' + record.category.downcase + '/individuals/' + record.id.to_s + '"><img src="' + get_attach_path(record) + '"></a>' : ' ',
        record.documents.where(fileattach_content_type: 'image/jpeg').any? ? '<a href="/individuals/' + record.id.to_s + '"><img src="' + get_attach_path(record)+ '"></a>' : ' ',
        link_to(record.number, @view.individual_path(record)),
        record.date_of_issue,
        record.valid_thru,
        record.license_status,
        record.call_sign,
        record.category,
        record.transmitter_power,
        record.certificate.present? ? link_to(record.certificate.fullname, @view.certificate_path(record.certificate.category.downcase, record.certificate)) : ' ',
        link_to(record.customer.fullname_and_address, @view.customer_path(record.customer)),
        record.category 
      ]
    end
  end

  def get_attach_path(record)
    attachment_url(record.documents.where(fileattach_content_type: ['image/jpeg', 'image/png']).last, :fileattach, :fill, 54, 77, format: 'jpg')
  end

  def get_raw_records
    #Individual.joins(:certificate, :customer).includes(:certificate, :customer).references(:certificate, :customer).all 
    Individual.joins(:customer).includes(:certificate, :customer).references(:certificate, :customer).all 
  end

  # ==== Insert 'presenter'-like methods below if necessary
end


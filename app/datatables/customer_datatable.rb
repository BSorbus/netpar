class CustomerDatatable < AjaxDatatablesRails::Base
  # uncomment the appropriate paginator module,
  # depending on gems available in your project.
 include AjaxDatatablesRails::Extensions::Kaminari
  # include AjaxDatatablesRails::Extensions::WillPaginate
  # include AjaxDatatablesRails::Extensions::SimplePaginator

  def_delegators :@view, :link_to, :h, :mailto

  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'customers.email'
    @sortable_columns ||= %w( 
                              Customer.name 
                              Customer.given_names 
                              Customer.address_city 
                              Customer.address_street 
                              Customer.address_house 
                              Customer.address_number 
                              Customer.birth_date 
                              Customer.pesel 
                              Customer.nip 
                              Customer.regon 
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'customers.email'
    @searchable_columns ||= %w(
                              Customer.name 
                              Customer.given_names 
                              Customer.address_city 
                              Customer.address_street 
                              Customer.birth_date 
                              Customer.pesel 
                              Customer.nip 
                              Customer.regon 
                            )
  end

  private

  def data
    # comma separated list of the values for each cell of a table row
    # example: record.attribute,
    records.map do |record|
      [
        record.id,
        link_to(record.name, @view.customer_path(record)),
        record.given_names,
        record.address_city,
        record.address_street,
        record.address_house,
        record.address_number,
        record.birth_date,
        record.pesel,
        record.nip,
        record.regon      
      ]
    end
  end

  def get_raw_records
    Customer.all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end

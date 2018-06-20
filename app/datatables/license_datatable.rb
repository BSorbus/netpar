class LicenseDatatable < AjaxDatatablesRails::Base
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
                              License.department 
                              License.number 
                              License.date_of_issue 
                              License.valid_to 
                              License.status 
                              License.call_sign 
                              License.category 
                              License.applicant_name 
                              License.applicant_location 
                              License.enduser_name 
                              License.enduser_location 
                              License.operators 
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'customers.email'
    @searchable_columns ||= %w(
                              License.number 
                              License.call_sign 
                              License.applicant_name 
                              License.applicant_location 
                              License.enduser_name 
                              License.enduser_location 
                              License.operators 
                            )
  end

  private

  def data
    # comma separated list of the values for each cell of a table row
    # example: record.attribute,
    records.map do |record|
      [
        record.id,
        record.department,
        record.number,
        record.date_of_issue,
        record.valid_to,
        record.status,
        record.call_sign,
        record.category,
        record.applicant_name,
        record.applicant_location,
        record.enduser_name,
        record.enduser_location,
        record.operators
      ]
    end
  end

  def get_raw_records
    License.all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end

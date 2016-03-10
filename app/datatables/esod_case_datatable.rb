class EsodCaseDatatable < AjaxDatatablesRails::Base
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
                              EsodCase.nrid 
                              EsodCase.znak 
                              EsodCase.symbol_jrwa 
                              EsodCase.tytul 
                              EsodCase.termin_realizacji 
                              EsodCase.identyfikator_kategorii_sprawy 
                              EsodCase.adnotacja 
                              EsodCase.identyfikator_stanowiska_referenta 
                              EsodCase.czy_otwarta 
                              EsodCase.esod_created_at 
                              EsodCase.esod_updated_et 
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'customers.email'
    @searchable_columns ||= %w(
                              EsodCase.nrid 
                              EsodCase.znak 
                              EsodCase.symbol_jrwa 
                              EsodCase.tytul 
                              EsodCase.termin_realizacji                             
                              EsodCase.identyfikator_kategorii_sprawy 
                              EsodCase.adnotacja 
                              EsodCase.identyfikator_stanowiska_referenta 
                              EsodCase.czy_otwarta 
                              EsodCase.esod_created_at 
                              EsodCase.esod_updated_et 
                            )
  end

  private

  def data
    # comma separated list of the values for each cell of a table row
    # example: record.attribute,
    records.map do |record|
      [
        record.id,
        record.nrid,
        record.znak,
        record.symbol_jrwa,
        record.tytul,
        record.termin_realizacji,
        record.identyfikator_kategorii_sprawy,
        record.adnotacja,
        record.identyfikator_stanowiska_referenta,
        record.czy_otwarta,
        record.esod_created_at,
        record.esod_updated_et      
      ]
    end
  end

  def get_raw_records
    EsodCase.all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end

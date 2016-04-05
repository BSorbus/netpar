class Esod::MatterDatatable < AjaxDatatablesRails::Base
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
                              Esod::Matter.nrid 
                              Esod::Matter.znak 
                              Esod::Matter.symbol_jrwa 
                              Esod::Matter.tytul 
                              Esod::Matter.termin_realizacji 
                              Esod::Matter.identyfikator_kategorii_sprawy 
                              Esod::Matter.adnotacja 
                              Esod::Matter.identyfikator_stanowiska_referenta 
                              Esod::Matter.czy_otwarta 
                              Esod::Matter.data_utworzenia 
                              Esod::Matter.data_modyfikacji 
                              Esod::Matter.initialized_from_esod 
                            )
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'customers.email'
    @searchable_columns ||= %w(
                              Esod::Matter.nrid 
                              Esod::Matter.znak 
                              Esod::Matter.symbol_jrwa 
                              Esod::Matter.tytul 
                              Esod::Matter.termin_realizacji                             
                              Esod::Matter.identyfikator_kategorii_sprawy 
                              Esod::Matter.adnotacja 
                              Esod::Matter.identyfikator_stanowiska_referenta 
                              Esod::Matter.czy_otwarta 
                              Esod::Matter.data_utworzenia 
                              Esod::Matter.data_modyfikacji 
                              Esod::Matter.initialized_from_esod 
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
        #record.znak,
        link_to(record.znak, @view.esod_matter_path(record)),
        record.symbol_jrwa,
        record.tytul,
        record.termin_realizacji,
        #record.identyfikator_kategorii_sprawy,
        record.iks_name,
        record.adnotacja,
        record.identyfikator_stanowiska_referenta,
        record.czy_otwarta,
        record.data_utworzenia,
        record.data_modyfikacji,      
        record.initialized_from_esod
      ]
    end
  end

  def get_raw_records
    Esod::Matter.all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end

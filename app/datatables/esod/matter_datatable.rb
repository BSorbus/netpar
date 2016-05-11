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
                              Esod::Matter.identyfikator_stanowiska_referenta 
                              Esod::Matter.czy_otwarta 
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
                              Esod::Matter.identyfikator_stanowiska_referenta 
                              Esod::Matter.czy_otwarta 
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
        link_to(record.znak, @view.esod_matter_path(record)),
        record.symbol_jrwa,
        record.tytul,
        record.termin_realizacji,
        record.iks_name,
        record.identyfikator_stanowiska_referenta,
        record.czy_otwarta,
      ]
    end
  end

  def get_raw_records
    collection_data = Esod::Matter.all
    if (options[:only_for_stanowisko_id]).present?
      collection_data = collection_data.where(identyfikator_stanowiska_referenta: options[:only_for_stanowisko_id]).all
    end
    if (options[:open]).present? && (options[:open]) != ""
      collection_data = collection_data.where(czy_otwarta: options[:open]).all
    end
    return collection_data
  end

  # ==== Insert 'presenter'-like methods below if necessary
end

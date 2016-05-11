require 'esodes'

class AddEsodCategoryToCertificate < ActiveRecord::Migration

  def get_esod_category(cert)
    e = cert.examination
    if e.present?
      e.esod_category
    else
      if cert.exam.esod_category == Esodes::SESJA_BEZ_EGZAMINOW
        if cert.certificate_status == 'O'
          Esodes::ODNOWIENIE_BEZ_EGZAMINU
        else
          Esodes::SWIADECTWO_BEZ_EGZAMINU
        end
      else
        Esodes::EGZAMIN
      end
    end
  end

  def up
    add_column :certificates, :esod_category, :integer

    #case certificate_status
    #when 'D'
    #  'Duplicat'   
    #when 'N'
    #  'Nowe'
    #when 'O'
    #  'Odnowione' 
    #when 'S'
    #  'Skreślone (nieważne)' 
    #when 'W'
    #  'Wymienione (odnowione)' 
    #else
    #  'Error certificate_status value !'
    #end

    Certificate.where(certificate_status: 'S').update_all(canceled: true)

    Certificate.where(certificate_status: 'D').update_all(esod_category: Esodes::DUPLIKAT) #DUPLIKAT = 45
    Certificate.where(certificate_status: 'W').update_all(esod_category: Esodes::WYMIANA) #WYMIANA = 46

    Certificate.where.not(certificate_status: ['S', 'D', 'W']).all.each do |c|
      c.update_attribute :esod_category, get_esod_category(c)
    end

  end

  def down
    remove_column :certificates, :esod_category
  end

end

class AddEsodCategoryToCertificate < ActiveRecord::Migration
  def up
    add_column :certificates, :esod_category, :integer

    #Examination.where(examination_category: 'Z', supplementary: false).update_all(esod_category: 41)
    #Examination.where(examination_category: 'P', supplementary: false).update_all(esod_category: 42)
    #Examination.where(examination_category: 'Z', supplementary: true).update_all(esod_category: 44)
    #Examination.where(examination_category: 'P', supplementary: true).update_all(esod_category: 49)
  end

  def down
    remove_column :certificates, :esod_category
  end

end

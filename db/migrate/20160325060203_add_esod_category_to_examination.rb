class AddEsodCategoryToExamination < ActiveRecord::Migration
  def up
    add_column :examinations, :esod_category, :integer

    Examination.where(examination_category: 'Z', supplementary: false).update_all(esod_category: 41)
    Examination.where(examination_category: 'P', supplementary: false).update_all(esod_category: 42)
    Examination.where(examination_category: 'Z', supplementary: true).update_all(esod_category: 44)
    Examination.where(examination_category: 'P', supplementary: true).update_all(esod_category: 49)
  end

  def down
    remove_column :examinations, :esod_category
  end

end



#1) Wniosek o wydanie świadectwa (41)
#2) Wniosek o egzamin poprawkowy (42)
#3) Wniosek o odnowienie bez egzaminu (43)
#4) Wniosek o odnowienie z egzaminem (44) #(PW)
#9) Wniosek o odnowienie z egzaminem – egzamin poprawkowy (49) #(PW)
#5) Wniosek o duplikat (45)
#6) Wniosek o wymianę świadectwa (46)
#7) Sesja egzaminacyjna (47)
#8) Protokół egzaminacyjny (48)

class AddEsodCategoriesToSubject < ActiveRecord::Migration
  def up
    add_column :subjects, :esod_categories, :string, array: true, length: 30, using: 'gin', default: '{}'


    Subject.where(for_supplementary: false).update_all(esod_categories: "{41, 42}")
    Subject.where(for_supplementary: true).update_all(esod_categories: "{44, 49}")
  end

  def down
    remove_column :subjects, :esod_categories
  end

end



#1) Wniosek o wydanie świadectwa (41)
#2) Wniosek o egzamin poprawkowy (42)
#3) Wniosek o odnowienie bez egzaminu (43)
#4) Wniosek o odnowienie z egzaminem (44) #(PW)
#9) Wniosek o odnowienie z egzaminem, poprawkowy (49) #(PW)
#5) Wniosek o duplikat (45)
#6) Wniosek o wymianę świadectwa (46)
#7) Sesja egzaminacyjna (47)
#8) Protokół egzaminacyjny (48)

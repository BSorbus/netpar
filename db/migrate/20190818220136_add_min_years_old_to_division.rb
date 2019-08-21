class AddMinYearsOldToDivision < ActiveRecord::Migration
  def up
    add_column :divisions, :min_years_old, :integer, default: 0

    Division.where(category: 'M').where.not(short_name: ['SRC', 'VHF']).update_all(min_years_old: 18)
    Division.where(category: 'M', short_name: ['SRC', 'VHF']).update_all(min_years_old: 15)
    Division.where(category: 'R', short_name: 'A').update_all(min_years_old: 15)
    Division.where(category: 'R', short_name: 'C').update_all(min_years_old: 10)
  end

  def down
    remove_column :divisions, :min_years_old
  end

end

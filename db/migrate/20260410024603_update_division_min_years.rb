class UpdateDivisionMinYears < ActiveRecord::Migration

  DIVISION_R_1 = 22
  DIVISION_R_3 = 23

  def up

    division_r1 = Division.find DIVISION_R_1
    division_r1.update_columns(min_years_old: 0)

    division_r3 = Division.find DIVISION_R_3
    division_r3.update_columns(min_years_old: 0)

  end

  def down

    division_r1 = Division.find DIVISION_R_1
    division_r1.update_columns(min_years_old: 15)

    division_r3 = Division.find DIVISION_R_3
    division_r3.update_columns(min_years_old: 10)

  end
end

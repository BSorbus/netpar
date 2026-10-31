# Wymóg zdjęcia w zgłoszeniu (z ustawienia rodzaju divisions.face_image_required w chwili zgłoszenia) – przekazywany
# przez Egzaminy (examinations8) w POST/PATCH /api/v1/proposals, jak division_min_years_old.
class AddDivisionFaceImageRequiredToProposals < ActiveRecord::Migration
  def up
    add_column :proposals, :division_face_image_required, :boolean, default: false, null: false
    # Istniejące zgłoszenia – wg obecnego ustawienia rodzaju.
    execute <<-SQL
      UPDATE proposals SET division_face_image_required = divisions.face_image_required
      FROM divisions WHERE divisions.id = proposals.division_id AND divisions.face_image_required IS NOT NULL
    SQL
  end

  def down
    remove_column :proposals, :division_face_image_required
  end
end

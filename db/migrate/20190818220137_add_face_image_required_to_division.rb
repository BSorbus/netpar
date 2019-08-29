class AddFaceImageRequiredToDivision < ActiveRecord::Migration
  def up
    add_column :divisions, :face_image_required, :boolean, default: false

    Division.where(category: 'M').update_all(face_image_required: true)

    # id: 9, short_name: "G1E", 
    # id: 10, short_name: "G2E",
    # id: 11, short_name: "GOC", 
    # id: 12, short_name: "ROC",
    # id: 13, short_name: "LRC",
    # id: 14, short_name: "SRC", 
    # id: 15, short_name: "VHF",
    # id: 16, short_name: "CSO",
    # id: 17, short_name: "IWC"

  end

  def down
    remove_column :divisions, :face_image_required
  end

end

class Document < ActiveRecord::Base
  belongs_to :documentable, polymorphic: true

  attachment :fileattach

  has_many :works, as: :trackable

  def fullname_and_id
    "#{fileattach_filename} (#{id})"
  end

end

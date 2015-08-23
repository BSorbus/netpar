class Document < ActiveRecord::Base
  belongs_to :documentable, polymorphic: true

  attachment :fileattach

end

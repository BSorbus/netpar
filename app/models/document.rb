class Document < ActiveRecord::Base
  belongs_to :documentable, polymorphic: true

  attachment :fileattach

  has_many :works, as: :trackable

  validates :fileattach, presence: true
  validates_numericality_of :fileattach_size, less_than: 10.megabytes.to_i 
  #validates :fileattach_filename, presence: true

  def fullname_and_id
    "#{fileattach_filename} (#{id})"
  end

end

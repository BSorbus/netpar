class Nationality < ActiveRecord::Base



  # scopes
  scope :by_short, -> { order(:short) }
  scope :by_name, -> { order(:name) }

  def fullname
    "#{name} - #{short}"
  end

end

# Represents examinees customers
# create_table "examinations", force: :cascade do |t|
#    t.string   "examination_category", limit: 1, default: "Z", null: false
#    t.integer  "division_id"
#    t.string   "examination_result",   limit: 1
#    t.integer  "exam_id"
#    t.integer  "customer_id"
#    t.text     "note",                           default: ""
#    t.string   "category",             limit: 1
#    t.integer  "user_id"
#    t.datetime "created_at",                                   null: false
#    t.datetime "updated_at",                                   null: false
#    t.integer  "certificate_id"
#  end
#  add_index "examinations", ["certificate_id"], name: "index_examinations_on_certificate_id", using: :btree
#  add_index "examinations", ["customer_id"], name: "index_examinations_on_customer_id", using: :btree
#  add_index "examinations", ["division_id"], name: "index_examinations_on_division_id", using: :btree
#  add_index "examinations", ["exam_id"], name: "index_examinations_on_exam_id", using: :btree
#  add_index "examinations", ["user_id"], name: "index_examinations_on_user_id", using: :btree
#
class Examination < ActiveRecord::Base
  belongs_to :division
  belongs_to :exam
  belongs_to :customer
  belongs_to :user

  belongs_to :certificate 

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Examination", dependent: :destroy

  has_many :grades, dependent: :destroy  

  accepts_nested_attributes_for :grades
  validates_associated :grades


  # validates

  


  # scopes
  scope :only_category_l, -> { where(category: "L") }
  scope :only_category_m, -> { where(category: "M") }
  scope :only_category_r, -> { where(category: "R") }

  def fullname
    "#{customer.fullname}  =>  #{exam.fullname}"
  end

  def fullname_and_id
    "#{customer.fullname}  =>  #{exam.fullname} (#{id})"
  end

  def examination_category_name
    case examination_category
    when 'Z'
      'Zwykły'
    when 'P'
      'Powtórny'
    else
      'Error !'
    end  
  end

  def examination_result_name
    case examination_result
    when 'B'
      'Negatywny bez prawa do powtórki'
    when 'N'
      'Negatywny z prawem do powtórki'
    when 'P'
      'Pozytywny'
    when '', nil
      ''
    else
      'Error !'
    end  
  end

  def generate_certificate(gen_user_id)
    exam = self.exam

    new_certificate = exam.certificates.create(number: Certificate.next_certificate_number(self.category, self.division), date_of_issue: Time.zone.today, user_id: gen_user_id, customer: self.customer, division: self.division, category: exam.category)
    self.certificate = new_certificate
    self.save! 
    new_certificate.works.create( trackable_url: "#{Rails.application.routes.url_helpers.certificate_path(new_certificate, category_service: new_certificate.category.downcase)}", action: :generate_certificate, user_id: gen_user_id, 
      parameters: new_certificate.to_json )

  end


end

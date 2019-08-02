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
#    t.string   "esod_categories",   default: [],                 array: true
FactoryBot.define do 
  factory :examination do
    division nil
    examination_result "?"
    exam nil
    customer nil
    note "MyText"
    category "MyString"
    user nil
    certificate nil
    esod_category 1

    trait :lot do
      category 'L'
    end

    trait :mor do
      category 'M'
    end

    trait :ra do
      category 'R'
    end

  end

end

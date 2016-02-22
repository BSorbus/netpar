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
#    t.boolean  "supplementary",                  default: false, null: false
FactoryGirl.define do
  factory :examination do
    examination_category "Z"
    division nil
    examination_result "?"
    exam nil
    customer nil
    note "MyText"
    category "MyString"
    user nil
    certificate nil
    supplementary false

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

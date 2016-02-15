FactoryGirl.define do
  factory :document do
    fileattach_filename "MyString"
    fileattach_content_type "MyString"
    fileattach_size 1
    documentable nil
    #documentable_id nil
    documentable_type "MyString"
  end

end

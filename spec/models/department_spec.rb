#require 'rails_helper'
#
#RSpec.describe Department, type: :model do
#  pending "add some examples to (or delete) #{__FILE__}"
#end


require 'spec_helper'

RSpec.describe Department, type: :model do
  let(:department) { FactoryGirl.build :department }
  subject { department }

  it { should respond_to(:short) }
  it { should respond_to(:name) }
  it { should respond_to(:address_city) }
  it { should respond_to(:address_street) }
  it { should respond_to(:address_house) }
  it { should respond_to(:address_number) }
  it { should respond_to(:address_postal_code) }
  it { should respond_to(:phone) }
  it { should respond_to(:fax) }
  it { should respond_to(:email) }
  it { should respond_to(:director) }
end

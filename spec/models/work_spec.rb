require 'rails_helper'

RSpec.describe Work, type: :model do
  let(:work) { FactoryGirl.build :work }
  subject { work }

  it { should respond_to(:trackable_id) }
  it { should respond_to(:trackable_type) }
  it { should respond_to(:trackable_url) }
  it { should respond_to(:user_id) }
  it { should respond_to(:action) }

  it { should belong_to :trackable }
  it { should belong_to :user }

end

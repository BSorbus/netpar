RSpec.describe User, type: :model do
  before(:each) { @user = User.new(email: 'user@uke.gov.pl') }

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:name) }
  it { should respond_to(:authentication_token) }

  it '#email returns a string' do
    expect(@user.email).to match 'user@uke.gov.pl'
  end

  it { should have_and_belong_to_many(:roles) }

  it { should belong_to :department }

  it { should have_many(:certificates) }
  it { should have_many(:customers) }
  it { should have_many(:exams) }

  it { should have_many(:documents) }
  it { should have_many(:works) }
  it { should have_many(:trackables) }
end

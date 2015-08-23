describe User do

  before(:each) { @user = User.new(email: 'user@uke.gov.pl') }

  subject { @user }

  it { should respond_to(:email) }

  it "#email returns a string" do
    expect(@user.email).to match 'user@uke.gov.pl'
  end

end

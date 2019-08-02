require 'rails_helper'

RSpec.describe Document, type: :model do
  let(:document) { FactoryBot.build :document }
  subject { document }

  it { should respond_to(:fileattach_filename) }
  it { should respond_to(:fileattach_content_type) }
  it { should respond_to(:fileattach_size) }
  it { should respond_to(:documentable_id) }
  it { should respond_to(:documentable_type) }

  it { should belong_to :documentable }

  it { should have_many(:works) }
end

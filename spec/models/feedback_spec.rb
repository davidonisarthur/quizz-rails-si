require 'rails_helper'

RSpec.describe Feedback, type: :model do
  describe 'associations' do
    it { should belong_to(:question) }
  end

  describe 'validations' do
    it { should validate_presence_of(:kind) }
    it { should validate_inclusion_of(:kind).in_array(%w[correct incorrect]) }
    it { should validate_presence_of(:body_pt) }
  end
end

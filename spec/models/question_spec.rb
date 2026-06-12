require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should belong_to(:quiz_module) }
    it { should have_many(:options).dependent(:destroy) }
    it { should have_many(:feedbacks).dependent(:destroy) }
  end
end

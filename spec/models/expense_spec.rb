# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe "associations" do
    it { should validate_presence_of :description }
    it { should validate_presence_of :date }
    it { should validate_presence_of :amount }
    it { should validate_presence_of :location }
    it { should validate_presence_of :status }
    it { should belong_to(:user) }
    it { should have_and_belong_to_many(:tags) }
  end

  describe "relationship" do
    let!(:user) { create(:user, :employee) }
    let!(:expense) { create(:expense, :pending, user: user) }
    let!(:tag) { create(:tag) }

    it 'allows association and access to the tags' do
      expense.tags << tag

      expect(expense.tags).to include(tag)
      expect(tag.expenses).to include(expense)
    end

    it 'allows deletion of a tag' do
      expense.tags << tag
      expense.tags.destroy(tag)

      expect(expense.tags).to_not include(tag)
    end
  end
end

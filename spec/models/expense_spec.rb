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
    it { should validate_inclusion_of(:role).in_array(%w[P A D]) }
  end
end

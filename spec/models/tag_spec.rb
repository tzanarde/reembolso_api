# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { should validate_presence_of :description }
  end
end

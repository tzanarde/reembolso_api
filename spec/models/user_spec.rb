# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:child_user).class_name("User").with_foreign_key("manager_user_id").dependent(:nullify) }
    it { should belong_to(:manager_user).class_name("User").optional }
    it { should have_many(:expenses) }
  end
end

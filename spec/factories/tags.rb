# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    sequence(:description) { |n| "Tag #{n}" }
  end
end

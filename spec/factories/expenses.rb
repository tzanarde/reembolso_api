# frozen_string_literal: true

FactoryBot.define do
  factory :expense do
    sequence(:description) { |n| "Descrição da despesas #{n}" }
    sequence(:date) { |n| (Date.today - n).strftime("%Y-%m-%d") }
    amount { rand(10.00..100.00).round(2) }
    sequence(:location) { |n| "Local #{n}" }
    user

    trait :pending do
      status { "P" }
    end

    trait :approved do
      status { "A" }
    end

    trait :declined do
      status { "D" }
    end
  end
end

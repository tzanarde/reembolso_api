# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    password { "password" }
    active { true }

    trait :manager do
      sequence(:email) { |n| "manager#{n}@email.com" }
      name { "Manager Name" }
      role { "Manager" }
      manager_user_id { nil }
    end

    trait :employee do
      sequence(:email) { |n| "employee#{n}@email.com" }
      name { "Employee Name" }
      role { "Employee" }
      manager_user_id { nil }
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    password { "password" }
    active { true }

    trait :manager do
      email { "manager@email.com" }
      name { "Manager Name" }
      role { "Manager" }
      manager_user_id { nil }
    end

    trait :employee do
      email { "employee@email.com" }
      name { "Employee Name" }
      role { "Employee" }
      manager_user_id { nil }
    end
  end
end

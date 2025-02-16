# frozen_string_literal: true

class Expense < ApplicationRecord
  validates :description, :date, :amount, :location, :status, presence: true
  validates :status, inclusion: { in: %w[P A D], message: "%{value} não é um status válido!" }

  belongs_to :user
end

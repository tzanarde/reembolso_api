# frozen_string_literal: true

class Tag < ApplicationRecord
  validates :description, presence: true

  has_and_belongs_to_many :expenses
end

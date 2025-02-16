# frozen_string_literal: true

class Tag < ApplicationRecord
  validates :description, presence: true
end

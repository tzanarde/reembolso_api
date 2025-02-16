# frozen_string_literal: true

class Tags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :description, null: false
    end
  end
end

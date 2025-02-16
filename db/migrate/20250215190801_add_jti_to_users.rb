# frozen_string_literal: true

class AddJtiToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :jti, :string
  end
end

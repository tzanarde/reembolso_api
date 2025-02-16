# frozen_string_literal: true

class AddFildsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :string
    add_column :users, :manager_user_id, :integer
    add_foreign_key :users, :users, column: :manager_user_id
    add_index :users, :manager_user_id
    add_column :users, :active, :boolean
  end
end

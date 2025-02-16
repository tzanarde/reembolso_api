class CreateExpenses < ActiveRecord::Migration[7.2]
  def change
    create_table :expenses do |t|
      t.string :description
      t.date :date
      t.decimal :amount
      t.string :location
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

# frozen_string_literal: true

class ExpenseSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :date,
             :amount,
             :location,
             :status,
             :manager,
             :employee

  def manager
    object.user.manager_user&.slice(:id, :name)
  end

  def employee
    object.user&.slice(:id, :name)
  end
end

# frozen_string_literal: true

class ExpenseSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :date,
             :amount,
             :location,
             :status,
             :manager,
             :employee,
             :tags

  def manager
    object.user.manager_user&.slice(:id, :name)
  end

  def employee
    object.user&.slice(:id, :name)
  end

  def tags
    object.tags.map(&:description)
  end
end

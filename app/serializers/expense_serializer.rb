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
             :tags,
             :receipts

  def manager
    object.user.manager_user&.slice(:id, :name)
  end

  def employee
    object.user&.slice(:id, :name)
  end

  def tags
    object.tags.map(&:description)
  end

  def receipts
    { receipt_nf: object.receipt_nf.filename, receipt_card: object.receipt_card.filename }
  end
end

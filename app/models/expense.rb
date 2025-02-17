# frozen_string_literal: true

class Expense < ApplicationRecord
  validates :description, :date, :amount, :location, :status, presence: true
  validates :status, inclusion: { in: %w[P A D], message: "%{value} não é um status válido!" }

  belongs_to :user
  has_and_belongs_to_many :tags

  delegate :manager_user, to: :user, allow_nil: true

  scope :pending, ->(type) do
    where(status: "P") if type.present? and type == "P"
  end

  scope :history, ->(type) do
    where("status IN ('A', 'D')") if type.present? and type == "H"
  end

  scope :by_date, ->(date) do
    where(date: date) if date.present?
  end

  scope :by_date_period, ->(start_date, final_date) do
    expense = where("date BETWEEN ? AND ?", start_date, final_date) if start_date.present? and final_date.present?
    expense = where("date BETWEEN ? AND ?", start_date, Date.today.to_s) if start_date.present? and final_date.nil?

    expense
  end

  scope :by_employee_id, ->(employee_id) do
    where(user_id: employee_id) if employee_id.present?
  end

  scope :by_amount, ->(min_amount, max_amount) do
    where("amount >= ? AND amount <= ?", min_amount, max_amount) if min_amount.present? and max_amount.present?
  end

  def self.filter(params)
    expenses = all
    expenses = expenses.pending(params[:type]) if params[:type].present? and params[:type] == "P"
    expenses = expenses.history(params[:type]) if params[:type].present? and params[:type] == "H"
    expenses = expenses.by_date(params[:date]) if params[:date].present?
    expenses = expenses.by_date_period(params[:start_date], params[:final_date]) if params[:start_date].present?
    expenses = expenses.by_employee_id(params[:employee_id]) if params[:employee_id].present?
    if params[:min_amount].present? and params[:max_amount].present?
      expenses = expenses.by_amount(params[:min_amount], params[:max_amount])
    end

    expenses
  end
end

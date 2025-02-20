# frozen_string_literal: true

class Expense < ApplicationRecord
  validates :description, :date, :amount, :location, :status, presence: true
  validates :status, inclusion: { in: %w[P A D], message: "%{value} não é um status válido!" }

  belongs_to :user
  has_and_belongs_to_many :tags

  has_one_attached :receipt_nf
  has_one_attached :receipt_card

  delegate :manager_user, to: :user, allow_nil: true

  scope :by_text_filter, ->(text_filter) do
    where("Upper(description) LIKE Upper('%#{text_filter}%')") if text_filter.present?
  end

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

  scope :by_tags, ->(tags) do
    joins(:tags).where(tags: { description: tags }).distinct if tags.present?
  end

  def self.filter(params)
    all.pending(params[:type])
       .history(params[:type])
       .by_text_filter(params[:text_filter])
       .by_date(params[:date])
       .by_date_period(params[:start_date], params[:final_date])
       .by_employee_id(params[:employee_id])
       .by_amount(params[:min_amount], params[:max_amount])
       .by_tags(params[:tags])
  end

  def add_tags(param_tags)
    param_tags.each { |tag| tags << Tag.find_or_create_by(description: tag) }
  end

  def update_tags(param_tags)
    tags_to_remove = if param_tags.count == 0
      tags
    else
      tags - param_tags
    end
    tags_to_add = param_tags - tags

    tags_to_remove.each { |tag| tags.destroy(tag) }
    tags_to_add.each { |tag| tags << Tag.find_or_create_by(description: tag) }
  end
end

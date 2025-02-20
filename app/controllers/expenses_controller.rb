class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[ show update destroy ]

  def index
    @expenses = Expense.filter(params).includes(user: :manager_user)

    render json: @expenses, each_serializer: ExpenseSerializer
  end

  def show
    render json: @expense
  end

  def create
    @expense = Expense.new(expense_params)

    if @expense.save
      @expense.receipt_nf.attach(params[:receipt_nf]) if valid_receipt? params[:receipt_nf]
      @expense.receipt_card.attach(params[:receipt_card]) if valid_receipt? params[:receipt_card]
      @expense.add_tags(params[:tags]) if params[:tags].present? and params[:tags].count > 0

      render json: @expense, status: :created, location: @expense
    else
      render json: @expense.errors, status: :unprocessable_entity
    end
  end

  def update
    if @expense.update(expense_params)
      @expense.update_tags(params[:tags]) unless params[:tags].nil?

      render json: @expense
    else
      render json: @expense.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy!
  end

  private
    def set_expense
      @expense = Expense.find(params[:id])
    end

    def expense_params
      params.permit(:description,
                    :date,
                    :amount,
                    :location,
                    :status,
                    :user_id,
                    :text_filter,
                    :receipt_nf,
                    :receipt_card)
    end

    def valid_receipt?(receipt)
      receipt.present? and
      (receipt.is_a?(ActionDispatch::Http::UploadedFile) or receipt.is_a?(Rack::Test::UploadedFile))
    end
end

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
      render json: @expense, status: :created, location: @expense
    else
      render json: @expense.errors, status: :unprocessable_entity
    end
  end

  def update
    if @expense.update(expense_params)
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
      params.require(:expense).permit(:description, :date, :amount, :location, :status, :user_id, :text_filter)
    end
end

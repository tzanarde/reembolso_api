class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show update destroy ]

  # def index
  #   @Users = user.all

  #   render json: @Users
  # end

  # def show
  #   render json: @user
  # end

  # def create
  #   @user = user.new(user_params)

  #   if @user.save
  #     render json: @user, status: :created, location: @user
  #   else
  #     render json: @user.errors, status: :unprocessable_entity
  #   end
  # end

  # def update
  #   if @user.update(user_params)
  #     render json: @user
  #   else
  #     render json: @user.errors, status: :unprocessable_entity
  #   end
  # end

  def destroy
    binding.pry
    # @user.destroy!
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    # def user_params
    #   params.require(:user).permit(:description)
    # end
end

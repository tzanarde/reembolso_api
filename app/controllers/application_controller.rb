# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  protected

  def permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :email, :password, :name, :role, :manager_user_id, :active ])
  end
end

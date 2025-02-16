# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    user = User.find_for_authentication(email: params[:user][:email])

    if user&.valid_password?(params[:user][:password])
      sign_in(:user, user)
      respond_with(user)
    else
      render json: { error: "E-mail ou senha inválidos!" }, status: :unauthorized
    end
  end

  def destroy
    if request.headers["Authorization"].present?
      token = request.headers["Authorization"].split(" ").last
      jwt_payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      user = User.find_by(id: jwt_payload["sub"])

      if user && user.jti == jwt_payload["jti"]
        user.update!(jti: SecureRandom.uuid)
        render json: { message: "Logout realizado com sucesso!" }, status: :ok
      else
        render json: { error: "Token já revogado!" }, status: :unauthorized
      end
    else
      render json: { error: "Token não fornecido!" }, status: :unprocessable_entity
    end
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      token = request.env["warden-jwt_auth.token"]
      token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first
      response.set_header("Authorization", "Bearer #{token}")
      render json: { user: resource, token: token, message: "Login realizado com sucesso!" }, status: :ok
    else
      render json: { error: "E-mail ou senha inválidos!" }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    head :no_content
  end

  def set_flash_message!(*_args)
  end
end

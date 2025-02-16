# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  include Devise::JWT::RevocationStrategies::JTIMatcher

  belongs_to :manager_user, class_name: "User", optional: true
  has_many :child_user, class_name: "User", foreign_key: "manager_user_id", dependent: :nullify

  def self.jwt_revoked?(payload, user)
    user.jti != payload["jti"]
  end

  def self.revoke_jwt(payload, user)
    user.update!(jti: SecureRandom.uuid)
  end
end

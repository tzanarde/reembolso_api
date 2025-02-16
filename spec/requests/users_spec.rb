# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "POST /users" do
    let(:headers) { { "Content-Type" => "application/json", "ACCEPT" => "application/json" } }
    context "for a manager user" do
      let(:valid_params) { { user: attributes_for(:user, :manager) }.to_json }
      it "creates a new manager user" do
        expect {
          post "/users", params: valid_params, headers: headers
        }.to change(User, :count).by 1

        expect(response).to have_http_status(:created)

        request_response = JSON.parse(response.body)["user"]
        expected_response = JSON.parse(valid_params)["user"]
        expected_response["id"] = request_response["id"]
        expect(request_response.except("created_at", "updated_at", "jti")).to eq(expected_response.except("password"))
      end
    end

    context "for an employee user" do
      let(:manager) { build(:user, :manager) }
      let(:valid_params) do
         { user: attributes_for(:user, :employee).merge(manager_user_id: manager.id) }
                                                 .to_json
      end
      it "creates a new employee user associated to a manager" do
        expect {
          post "/users", params: valid_params, headers: headers
        }.to change(User, :count).by 1

        expect(response).to have_http_status(:created)

        request_response = JSON.parse(response.body)["user"]
        expected_response = JSON.parse(valid_params)["user"]
        expected_response["id"] = request_response["id"]
        expect(request_response.except("created_at", "updated_at", "jti")).to eq(expected_response.except("password"))
      end
    end
  end

  describe "POST /users/sign_in" do
    let(:headers) { { "Content-Type" => "application/json", "ACCEPT" => "application/json" } }
    let!(:manager) { create(:user, :manager) }
    context "for a manager user" do
      context "with valid credentials" do
        let(:valid_params) { { user: attributes_for(:user, :manager).slice(:email, :password) }.to_json }
        it "logs in with a manager user" do
          post "/users/sign_in", params: valid_params, headers: headers

          expect(response).to have_http_status(:ok)

          request_response = JSON.parse(response.body)
          expected_response = JSON.parse(valid_params)

          expect(request_response["user"]["email"]).to eq(expected_response["user"]["email"])
          expect(request_response["token"]).not_to eq(nil)
          expect(request_response["message"]).to eq("Login realizado com sucesso!")
        end
      end

      context "with invalid credentials" do
        context "for invalid email" do
          let(:valid_params) do
            { user: attributes_for(:user, :manager).slice(:email, :password)
                                                   .merge(email: 'incorrect_email@email.com') }
                                                   .to_json
          end
          it "returns unauthorized" do
            post "/users/sign_in", params: valid_params, headers: headers

            expect(response).to have_http_status(:unauthorized)
          end
        end

        context "for invalid password" do
          let(:valid_params) do
            { user: attributes_for(:user, :manager).slice(:email, :password)
                                                   .merge(password: 'incorrect_password') }
                                                   .to_json
          end
          it "returns unauthorized" do
            post "/users/sign_in", params: valid_params, headers: headers

            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end

  describe "DELETE /users/sign_out" do
    let(:headers_sign_in) { { "Content-Type" => "application/json", "ACCEPT" => "application/json" } }
    context "when the user is logged in" do
      let!(:manager) { create(:user, :manager) }
      context "with a valid token" do
        let(:valid_params) { { user: attributes_for(:user, :manager).slice(:email, :password) }.to_json }
        it "logs out a user" do
          post "/users/sign_in", params: valid_params, headers: headers_sign_in

          sign_in_request_response = JSON.parse(response.body)

          headers_sign_out = { "Content-Type" => "application/json",
                               "ACCEPT" => "application/json",
                               "Authorization" => sign_in_request_response["token"] }
          delete "/users/sign_out", params: valid_params, headers: headers_sign_out

          expect(response).to have_http_status(:ok)

          sign_out_request_response = JSON.parse(response.body)

          expect(sign_out_request_response["message"]).to eq("Logout realizado com sucesso!")
          expect(sign_in_request_response["user"]["jti"]).not_to eq(nil)
          expect(manager.jti).not_to eq(nil)
          expect(sign_in_request_response["user"]["jti"]).not_to eq(manager.reload.jti)
        end
      end

      context "when the user is logged out" do
        context "with a revoged token" do
          let(:valid_params) { { user: attributes_for(:user, :manager).slice(:email, :password) }.to_json }
          it "returns unauthorized" do
            post "/users/sign_in", params: valid_params, headers: headers_sign_in

            sign_in_request_response = JSON.parse(response.body)

            headers_sign_out = { "Content-Type" => "application/json",
                                "ACCEPT" => "application/json",
                                "Authorization" => sign_in_request_response["token"] }
            delete "/users/sign_out", params: valid_params, headers: headers_sign_out
            delete "/users/sign_out", params: valid_params, headers: headers_sign_out

            expect(response).to have_http_status(:unauthorized)

            sign_out_request_response = JSON.parse(response.body)

            expect(sign_out_request_response["error"]).to eq("Token já revogado!")
          end
        end
      end

      context "without a token" do
        let(:valid_params) { { user: attributes_for(:user, :manager).slice(:email, :password) }.to_json }
        it "returns unauthorized" do
          post "/users/sign_in", params: valid_params, headers: headers_sign_in

          headers_sign_out = { "Content-Type" => "application/json",
                               "ACCEPT" => "application/json",
                               "Authorization" => nil }
          delete "/users/sign_out", params: valid_params, headers: headers_sign_out
          delete "/users/sign_out", params: valid_params, headers: headers_sign_out

          expect(response).to have_http_status(:unprocessable_entity)

          sign_out_request_response = JSON.parse(response.body)

          expect(sign_out_request_response["error"]).to eq("Token não fornecido!")
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
include AuthHelpers

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
        let(:valid_params) { { user: manager.slice(:email, :password) }.to_json }
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
        let(:valid_params) { { user: manager.slice(:email, :password) }.to_json }
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
          let(:valid_params) { { user: manager.slice(:email, :password) }.to_json }
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
        let(:valid_params) { { user: manager.slice(:email, :password) }.to_json }
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

  describe "DELETE /users" do
    context 'for an employee user' do
      context 'when an employee user tries to delete' do
        context 'when the employee user to be deleted is the logged in employee user' do
          context "when the employee user is logged in" do
            let!(:employee) { create(:user, :employee) }

            context 'when the employee user exists' do
              let(:user_token) { authenticate_user(employee) }
              let(:headers) { authenticated_user_headers(user_token) }

              it 'deletes an employee user' do
                delete "/user/#{employee.id}", headers: headers

                expect(response).to have_http_status(:no_content)
              end
            end

            context 'when the employee user does not exist' do
              let(:user_token) { authenticate_user(employee) }
              let(:headers) { authenticated_user_headers(user_token) }

              it 'returns not found' do
                delete "/user/999", headers: headers

                expect(response).to have_http_status(:not_found)
              end
            end
          end

          context "when the employee user is logged out" do
            let(:headers) { unauthenticated_user_headers }

            it 'returns unauthorized' do
              delete "/user/999", headers: headers

              expect(response).to have_http_status(:unauthorized)
            end
          end
        end

        context 'when the employee user to be deleted is not the logged in employee user' do
          let!(:employee_logged_in) { create(:user, :employee) }
          let!(:employee_to_delete) { create(:user, :employee) }
          let(:user_token) { authenticate_user(employee_logged_in) }
          let(:headers) { authenticated_user_headers(user_token) }

          it 'returns unauthorized' do
            delete "/user/#{user_to_delete.id}", headers: headers

            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      context 'when a manager user tries to delete the employee user' do
        let!(:manager) { create(:user, :manager) }
        let!(:employee_to_delete) { create(:user, :employee) }
        let(:user_token) { authenticate_user(manager) }
        let(:headers) { authenticated_user_headers(user_token) }

        it 'deletes an employee user' do
          delete "/user/#{employee_to_delete.id}", headers: headers

          expect(response).to have_http_status(:no_content)
        end
      end
    end

    context 'for a manager user' do
      context 'when a manager user tries to delete' do
        context 'when the manager user to be deleted is the logged in manager user' do
          context "when the manager user is logged in" do
            let!(:manager) { create(:user, :manager) }

            context 'when the manager user exists' do
              let(:user_token) { authenticate_user(manager) }
              let(:headers) { authenticated_user_headers(user_token) }

              it 'deletes the manager user' do
                delete "/user/#{manager.id}", headers: headers

                expect(response).to have_http_status(:no_content)
              end
            end

            context 'when the manager user does not exist' do
              let(:user_token) { authenticate_user(manager) }
              let(:headers) { authenticated_user_headers(user_token) }

              it 'returns not found' do
                delete "/user/999", headers: headers

                expect(response).to have_http_status(:not_found)
              end
            end
          end

          context "when the manager user is logged out" do
            let(:headers) { unauthenticated_user_headers }

            it 'returns unauthorized' do
              delete "/user/999", headers: headers

              expect(response).to have_http_status(:unauthorized)
            end
          end
        end

        context 'when the manager user to be deleted is the logged in manager user' do
          let!(:manager_logged_in) { create(:user, :manager) }
          let!(:manager_to_delete) { create(:user, :manager) }
          let(:user_token) { authenticate_user(manager_logged_in) }
          let(:headers) { authenticated_user_headers(user_token) }

          it 'returns unauthorized' do
            delete "/user/#{manager_to_delete.id}", headers: headers

            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      context 'when an employee user tries to delete' do
        let!(:employee) { create(:user, :employee) }
        let(:user_token) { authenticate_user(employee) }
        let(:headers) { authenticated_user_headers(user_token) }

        it 'returns unauthorized' do
          delete "/user/999", headers: headers

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end

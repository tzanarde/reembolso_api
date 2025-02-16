# frozen_string_literal: true

require 'rails_helper'
include AuthHelpers

RSpec.describe "Tags", type: :request do
  let!(:user) { create(:user, :manager) }

  describe "GET /tags" do
    context "when the user is logged in" do
      let(:user_token) { authenticate_user }
      let(:headers) { authenticated_user_headers(user_token) }
      let!(:tags) { create_list(:tag, 10) }

      it 'returns all tags' do
        get "/tags", headers: headers

        request_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(request_response.count).to eq(10)
        expect(request_response.first).to have_key("description")
        (0..9).each do |index|
          expect(request_response[index]["description"]).to eq(tags[index]["description"])
        end
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        get "/tags", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /tags/:id" do
    context "when the user is logged in" do
      context 'when the tag exists' do
        let(:user_token) { authenticate_user }
        let(:headers) { authenticated_user_headers(user_token) }
        let!(:tag) { create(:tag) }

        it 'returns the filtered tag' do
          get "/tags", params: tag.id, headers: headers

          request_response = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(request_response).to have_key("description")
          expect(request_response["description"]).to eq(tag["description"])
        end
      end

      context 'when the tag do not exist' do
        let(:user_token) { authenticate_user }
        let(:headers) { authenticated_user_headers(user_token) }

        it 'returns no content' do
          get "/tags", params: tag.id, headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        get "/tags", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /tags" do
    context "when the user is logged in" do
      let(:user_token) { authenticate_user }
      let(:headers) { authenticated_user_headers(user_token) }
      let!(:valid_params) { attributes_for(:tag) }

      it 'creates a tag' do
        post "/tags", params: valid_params, headers: headers

        request_response = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(request_response).to have_key("description")
        expect(request_response["description"]).to eq(valid_params["description"])
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        post "/tags", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /tags" do
    context "when the user is logged in" do
      context 'when the tag exists' do
        let(:user_token) { authenticate_user }
        let(:headers) { authenticated_user_headers(user_token) }
        let!(:tag) { create(:tag) }
        let(:valid_params) { { description: 'New Description' } }

        it 'updates a tag' do
          patch "/tags", params: valid_params, headers: headers

          request_response = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(request_response).to have_key("description")
          expect(request_response["description"]).not_to eq(tag["description"])
          expect(request_response["description"]).to eq(valid_params["description"])
        end
      end

      context 'when the tag do not exists' do
        let(:user_token) { authenticate_user }
        let(:headers) { authenticated_user_headers(user_token) }
        let(:valid_params) { { description: 'New Description' } }

        it 'updates a tag' do
          patch "/tags", params: valid_params, headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        patch "/tags", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /tags" do
    context "when the user is logged in" do
      context 'when the tag exists' do
        let(:user_token) { authenticate_user }
        let(:headers) { authenticated_user_headers(user_token) }
        let!(:tag) { create(:tag) }

        it 'updates a tag' do
          delete "/tags", params: valid_params, headers: headers

          request_response = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(request_response).to have_key("description")
          expect(request_response["description"]).to eq(tag["description"])
        end
      end

      context 'when the tag do not exists' do
        let(:user_token) { authenticate_user }
        let(:headers) { authenticated_user_headers(user_token) }
        let(:valid_params) { { description: 'New Description' } }

        it 'updates a tag' do
          delete "/tags", params: valid_params, headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        delete "/tags", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

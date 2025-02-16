# frozen_string_literal: true

require 'rails_helper'
include AuthHelpers

RSpec.describe "Expenses", type: :request do
  let!(:manager) { create(:user, :manager) }
  let!(:employee) do
    [ create(:user, :employee, manager_user_id: manager.id),
      create(:user, :employee, manager_user_id: manager.id) ]
  end

  describe "GET /expenses" do
    let!(:expenses) do
      [
        create(:expense, :pending, user: employee[0], amount: 10.00),
        create(:expense, :approved, user: employee[0], amount: 20.00),
        create(:expense, :declined, user: employee[0], amount: 30.00),
        create(:expense, :pending, user: employee[1], amount: 40.00),
        create(:expense, :approved, user: employee[1], amount: 50.00),
        create(:expense, :declined, user: employee[1], amount: 60.00)
      ]
    end

    context "when the user is logged in" do
      let(:user_token) { authenticate_user(manager) }
      let(:headers) { authenticated_user_headers(user_token) }

      context "without filters" do
        it 'returns all expenses' do
          get "/expenses", headers: headers

          request_response = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(request_response.count).to eq(6)
          expect(request_response.first).to include("description", "date", "amount", "location", "stats", "user")
          (1..6).each do |index|
            expect(request_response[index]["description"]).to eq(expenses[index]["description"])
          end
        end
      end

      context "with filters" do
        context "filtering for a manager" do
          context "for default filters" do
            let(:params) { { manager_user_id: manager.id } }

            it 'returns all expenses related to the manager' do
              get "/expenses", params: params, headers: headers

              request_response = JSON.parse(response.body)

              expect(response).to have_http_status(:ok)
              expect(request_response.count).to eq(6)
              (1..6).each do |index|
                expect(request_response[index]["manager_user_id"]).to eq(manager["id"])
              end
            end

            it 'returns all pending expenses related to the manager' do
              get "/expenses", params: params, headers: headers

              request_response = JSON.parse(response.body)

              expect(response).to have_http_status(:ok)
              expect(request_response.count).to eq(2)
              (1..2).each do |index|
                expect(request_response[index]["manager_user_id"]).to eq(manager["id"])
                expect(request_response[index]["status"]).to eq("P")
              end
            end

            it 'returns all expense history related to a manager' do
              get "/expenses", params: params, headers: headers

              request_response = JSON.parse(response.body)

              expect(response).to have_http_status(:ok)
              expect(request_response.count).to eq(4)
              (1..4).each do |index|
                expect(request_response[index]["manager_user_id"]).to eq(manager["id"])
                expect(request_response[index]["status"]).to be_in("A", "D")
              end
            end
          end

          context "for custom filters" do
            context "filtering by date" do
              context "specific day" do
                let(:params) { { manager_user_id: manager.id, date: Date.today - 2 } }
                it 'returns expenses related to the manager filtered by a specific day' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  expect(request_response["date"]).to eq(Date.today - 2)
                end
              end

              context "period of days with both start and final dates" do
                let(:params) { { manager_user_id: manager.id, start_date: Date.today - 2, final_date: Date.today } }
                it 'returns expenses related to the manager filtered by a period of days' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(3)
                  (1..3).each do |index|
                    expect(request_response[index]["date"]).to be_between(Date.today - 2, Date.today)
                  end
                end
              end

              context "period of days with only start date" do
                let(:params) { { manager_user_id: manager.id, start_date: Date.today - 2 } }
                it 'returns expenses related to the manager filtered by a period of days' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(3)
                  (1..3).each do |index|
                    expect(request_response[index]["date"]).to be >= (Date.today - 2)
                  end
                end
              end

              context "period of days with only final date" do
                let(:params) { { manager_user_id: manager.id, final_date: Date.today - 2 } }
                it 'returns expenses related to the manager filtered by a period of days' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(3)
                  (1..3).each do |index|
                    expect(request_response[index]["date"]).to be <= (Date.today - 2)
                  end
                end
              end
            end

            context "filtering by employee" do
              let(:params) { { manager_user_id: manager.id, employee_id: employee[0].id } }
              it 'returns expenses related to the manager filtered by an employee' do
                get "/expenses", params: params, headers: headers

                request_response = JSON.parse(response.body)

                expect(response).to have_http_status(:ok)
                expect(request_response.count).to eq(1)
                expect(request_response["user_id"]).to eq(employee[0].id)
              end
            end

            context "filtering by tags" do
              context "with only one tag" do
                let!(:tag) { create(:tag) }
                let(:params) { { manager_user_id: manager.id, tags: tag } }
                it 'returns expenses related to the manager filtered by a tag' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  expect(request_response["tags"].count).to eq(1)
                  expect(request_response["tags"]).to eq(tag)
                end
              end

              context "with multiple tags" do
                let!(:tags) { create_list(:tag, 10) }
                let(:params) { { manager_user_id: manager.id, tags: tag } }
                it 'returns expenses related to the manager filtered by a tag' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  expect(request_response["tags"].count).to eq(10)
                  expect(request_response["tags"]).to eq(tags)
                end
              end
            end

            context "filtering by amount" do
              let(:params) { { manager_user_id: manager.id, min_amount: 0.00, max_amount: 50.00 } }
              it 'returns expenses related to the manager filtered by amount' do
                get "/expenses", params: params, headers: headers

                request_response = JSON.parse(response.body)

                expect(response).to have_http_status(:ok)
                expect(request_response.count).to eq(5)
                (1..5).each do |index|
                  expect(request_response[index]["amount"]).to be_between(params[:min_amount], params[:max_amount])
                end
              end
            end
          end
        end

        context "filtering for a employee" do
          context "for default filters" do
            let(:params) { { user_id: employee[0].id } }
            it 'returns all expenses that belongs to the employee' do
              get "/expenses", params: params, headers: headers

              request_response = JSON.parse(response.body)

              expect(response).to have_http_status(:ok)
              expect(request_response.count).to eq(3)
              (1..3).each do |index|
                expect(request_response[index]["user_id"]).to eq(employee[0].id)
              end
            end

            it 'returns all pending expenses that belongs to the employee' do
              get "/expenses", params: params, headers: headers

              request_response = JSON.parse(response.body)

              expect(response).to have_http_status(:ok)
              expect(request_response.count).to eq(1)
              expect(request_response[index]["user_id"]).to eq(employee[0].id)
              expect(request_response["status"]).to eq("P")
            end

            it 'returns all expense history that belongs to the employee' do
              get "/expenses", params: params, headers: headers

              request_response = JSON.parse(response.body)

              expect(response).to have_http_status(:ok)
              expect(request_response.count).to eq(2)
              (1..2).each do |index|
                expect(request_response[index]["user_id"]).to eq(employee[0].id)
                expect(request_response[index]["status"]).to be_in("A", "D")
              end
            end
          end

          context "for custom filters" do
            context "filtering by date" do
              context "specific day" do
                let(:params) { { user_id: employee[0].id, date: Date.today } }
                it 'returns expenses that belongs to the employee filtered by a specific day' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  expect(request_response["date"]).to eq(Date.today)
                end
              end

              context "period of days with both start and final dates" do
                let(:params) { { user_id: employee[0].id, start_date: Date.today - 2, final_date: Date.today } }
                it 'returns expenses that belongs to the employee filtered by a period of days' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  expect(request_response["date"]).to be_between(Date.today - 2, Date.today)
                end
              end

              context "period of days with only start date" do
                let(:params) { { user_id: employee[0].id, start_date: Date.today } }
                it 'returns expenses that belongs to the employee filtered by a period of days' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  expect(request_response["date"]).to be >= Date.today
                end
              end

              context "period of days with only final date" do
                let(:params) { { user_id: employee[0].id, final_date: Date.today } }
                it 'returns expenses that belongs to the employee filtered by a period of days' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  expect(request_response["date"]).to be <= Date.today
                end
              end
            end

            context "filtering by tags" do
              context "with only one tag" do
                let!(:tag) { create(:tag) }
                let(:params) { { user_id: employee[0].id, tags: tag } }
                it 'returns expenses that belongs to the employee filtered by a tag' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  expect(request_response["tags"].count).to eq(1)
                  expect(request_response["tags"]).to eq(tag)
                end
              end

              context "with multiple tags" do
                let!(:tags) { create_list(:tag, 10) }
                let(:params) { { user_id: employee[0].id, tags: tag } }
                it 'returns expenses that belongs to the employee filtered by a tag' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  expect(request_response["tags"].count).to eq(10)
                  expect(request_response["tags"]).to eq(tags)
                end
              end
            end

            context "filtering by amount" do
              let(:params) { { user_id: employee[0].id, min_amount: 0.00, max_amount: 20.00 } }
              it 'returns expenses that belongs to the employee filtered by amount' do
                get "/expenses", params: params, headers: headers

                request_response = JSON.parse(response.body)

                expect(response).to have_http_status(:ok)
                expect(request_response.count).to eq(2)
                (1..2).each do |index|
                  expect(request_response[index]["amount"]).to be_between(params[:min_amount], params[:max_amount])
                end
              end
            end
          end
        end
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        get "/expenses", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /expenses:id" do
    let!(:expense) { create(:expense, :pending, user: employee[0]) }

    context "when the user is logged in" do
      context 'when the tag exists' do
        let(:user_token) { authenticate_user(manager) }
        let(:headers) { authenticated_user_headers(user_token) }
        it 'returns an expense' do
          get "/expenses#{expense.id}", headers: headers

          request_response = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(request_response.count).to eq(6)
          expect(request_response.first).to include("description", "date", "amount", "location", "stats", "user")
          expect(request_response["description"]).to eq(expenses["description"])
        end
      end

      context 'when the expense does not exist' do
        let(:user_token) { authenticate_user(manager) }
        let(:headers) { authenticated_user_headers(user_token) }

        it 'returns not found' do
          get "/expenses/1", headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        get "/expenses/1", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /expenses" do
    context "when the user is logged in" do
      let(:user_token) { authenticate_user(manager) }
      let(:headers) { authenticated_user_headers(user_token) }
      let!(:valid_params) { attributes_for(:expense).to_json }

      it 'creates an expense' do
        post "/expenses", params: valid_params, headers: headers

        request_response = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(request_response).to have_key("description")
        expect(request_response["description"]).to eq(JSON.parse(valid_params)["description"])
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        post "/expenses", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /expenses" do
    context "when the user is logged in" do
      context 'when the expense exists' do
        let(:user_token) { authenticate_user(manager) }
        let(:headers) { authenticated_user_headers(user_token) }
        let!(:expense) { create(:expense) }
        let(:valid_params) { { description: 'New Description' }.to_json }

        it 'updates an expense' do
          patch "/expenses/#{expense.id}", params: valid_params, headers: headers

          request_response = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(request_response).to have_key("description")
          expect(request_response["description"]).not_to eq(expense["description"])
          expect(request_response["description"]).to eq(JSON.parse(valid_params)["description"])
        end
      end

      context 'when the expense does not exist' do
        let(:user_token) { authenticate_user(manager) }
        let(:headers) { authenticated_user_headers(user_token) }
        let(:valid_params) { { description: 'New Description' }.to_json }

        it 'returns not found' do
          patch "/expenses/1", params: valid_params, headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        patch "/expenses/1", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /expenses" do
    context "when the user is logged in" do
      context 'when the expenses exists' do
        let(:user_token) { authenticate_user(manager) }
        let(:headers) { authenticated_user_headers(user_token) }
        let!(:expense) { create(:expense) }

        it 'deletes an expense' do
          delete "/expenses/#{expense.id}", headers: headers

          expect(response).to have_http_status(:no_content)
        end
      end

      context 'when the expense does not exist' do
        let(:user_token) { authenticate_user(manager) }
        let(:headers) { authenticated_user_headers(user_token) }

        it 'returns not found' do
          delete "/expenses/1", headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is logged out" do
      let(:headers) { unauthenticated_user_headers }

      it 'returns unauthorized' do
        delete "/expenses/1", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

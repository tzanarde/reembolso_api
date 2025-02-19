# frozen_string_literal: true

require 'rails_helper'
include AuthHelpers
include MatchHelpers

RSpec.describe "Expenses", type: :request do
  let!(:manager) { create(:user, :manager) }
  let!(:employees) do
    [ create(:user, :employee, manager_user_id: manager.id),
      create(:user, :employee, manager_user_id: manager.id) ]
  end

  describe "GET /expenses" do
    let!(:expenses) do
      [
        create(:expense, :pending, user: employees[0], amount: 10.00),
        create(:expense, :approved, user: employees[0], amount: 20.00),
        create(:expense, :declined, user: employees[0], amount: 30.00),
        create(:expense, :pending, user: employees[1], amount: 40.00),
        create(:expense, :approved, user: employees[1], amount: 50.00),
        create(:expense, :declined, user: employees[1], amount: 60.00)
      ]
    end
    let!(:pending_expenses) { [ expenses[0], expenses[3] ] }
    let!(:history_expenses) { [ expenses[1], expenses[2], expenses[4], expenses[5] ] }
    let!(:employee_1_expenses) { [ expenses[0], expenses[1], expenses[2] ] }
    let!(:employee_2_expenses) { [ expenses[3], expenses[4], expenses[5] ] }

    context "when the user is logged in" do
      let(:user_token) { authenticate_user(manager) }
      let(:headers) { authenticated_user_headers(user_token) }

      context "without filters" do
        let(:testing_expenses) { expenses }
        let(:testing_employees) { employees }

        it 'returns all expenses' do
          get "/expenses", headers: headers

          request_response = JSON.parse(response.body)["expenses"]
          expect(response).to have_http_status(:ok)
          expect(request_response.count).to eq(6)
          match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
        end
      end

      context "with filters" do
        context "filtering for a manager" do
          context "for default filters" do
            context "without type" do
              let(:params) { { manager_user_id: manager.id } }
              let(:testing_expenses) { expenses }
              let(:testing_employees) { employees }

              it 'returns all expenses related to the manager' do
                get "/expenses", params: params, headers: headers

                request_response = JSON.parse(response.body)["expenses"]

                expect(response).to have_http_status(:ok)
                expect(request_response.count).to eq(6)
                match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
              end
            end

            context "for pending type" do
              let(:params) { { manager_user_id: manager.id, type: "P" } }
              let(:testing_expenses) { pending_expenses }
              let(:testing_employees) { employees }

              it 'returns all pending expenses related to the manager' do
                get "/expenses", params: params, headers: headers

                request_response = JSON.parse(response.body)["expenses"]

                expect(response).to have_http_status(:ok)
                expect(request_response.count).to eq(2)
                match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
              end
            end

            context "for history type" do
              let(:params) { { manager_user_id: manager.id, type: "H" } }
              let(:testing_expenses) { history_expenses }
              let(:testing_employees) { employees }

              it 'returns all expense history related to a manager' do
                get "/expenses", params: params, headers: headers

                request_response = JSON.parse(response.body)["expenses"]

                expect(response).to have_http_status(:ok)
                expect(request_response.count).to eq(4)
                match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
              end
            end
          end

          context "for custom filters" do
            context "searching for description" do
              let(:params) { { manager_user_id: manager.id, text_filter: expenses[3].description } }
              let(:testing_expenses) { [ expenses[3] ] }
              let(:testing_employees) { employees }

              it 'returns expenses related to the manager filtered by description' do
                get "/expenses", params: params, headers: headers

                request_response = JSON.parse(response.body)["expenses"]

                expect(response).to have_http_status(:ok)
                expect(request_response.count).to eq(1)
                match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
              end
            end

            context "filtering by date" do
              context "specific day" do
                let(:params) { { manager_user_id: manager.id, date: expenses[3].date } }
                let(:testing_expenses) { [ expenses[3] ] }
                let(:testing_employees) { employees }

                it 'returns expenses related to the manager filtered by a specific day' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)["expenses"]

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(1)
                  match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
                end
              end

              context "period of days with both start and final dates" do
                let(:params) do
                  { manager_user_id: manager.id, start_date: expenses[5].date, final_date: expenses[4].date }
                end
                let(:testing_expenses) { [ expenses[4], expenses[5] ] }
                let(:testing_employees) { [ employees[1], employees[1] ] }

                it 'returns expenses related to the manager filtered by a period of days' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)["expenses"]

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(2)
                  match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
                end
              end

              context "period of days with only start date" do
                let(:params) { { manager_user_id: manager.id, start_date: expenses[1].date } }
                let(:testing_expenses) { [ expenses[0], expenses[1] ] }
                let(:testing_employees) { [ employees[0], employees[0] ] }

                it 'returns expenses related to the manager filtered by a period of days' do
                  get "/expenses", params: params, headers: headers

                  request_response = JSON.parse(response.body)["expenses"]

                  expect(response).to have_http_status(:ok)
                  expect(request_response.count).to eq(2)
                  match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
                end
              end
            end

            context "filtering by employee" do
              let(:params) { { manager_user_id: manager.id, employee_id: employees[0].id } }
              let(:testing_expenses) { employee_1_expenses }
              let(:testing_employees) { [ employees[0], employees[0], employees[0] ] }

              it 'returns expenses related to the manager filtered by an employee' do
                get "/expenses", params: params, headers: headers

                request_response = JSON.parse(response.body)["expenses"]

                expect(response).to have_http_status(:ok)
                expect(request_response.count).to eq(3)
                match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
              end
            end

            context "filtering by amount" do
              let(:params) { { manager_user_id: manager.id, min_amount: 40.00, max_amount: 60.00 } }
              let(:testing_expenses) { employee_2_expenses }
              let(:testing_employees) { [ employees[1], employees[1], employees[1] ] }

              it 'returns expenses related to the manager filtered by amount' do
                get "/expenses", params: params, headers: headers

                request_response = JSON.parse(response.body)["expenses"]

                expect(response).to have_http_status(:ok)
                expect(request_response.count).to eq(3)
                match_expense_fields_index(request_response, testing_expenses, manager, testing_employees)
              end
            end

            # context "filtering by tags" do
            #   context "with only one tag" do
            #     let!(:tag) { create(:tag) }
            #     let(:params) { { manager_user_id: manager.id, tags: [ tag ] } }
            #     it 'returns expenses related to the manager filtered by a tag' do
            #       expenses.first.tags << tag
            #       get "/expenses", params: params, headers: headers

            #       request_response = JSON.parse(response.body)["expenses"]

            #       expect(response).to have_http_status(:ok)
            #       expect(request_response.count).to eq(1)
            #       expect(request_response["tags"].count).to eq(1)
            #       expect(request_response["tags"]).to eq(tag)
            #     end
            #   end

            #   context "with multiple tags" do
            #     let!(:tags) { create_list(:tag, 10) }
            #     let(:params) { { manager_user_id: manager.id, tags: tag } }
            #     it 'returns expenses related to the manager filtered by a tag' do
            #       get "/expenses", params: params, headers: headers

            #       request_response = JSON.parse(response.body)["expenses"]

            #       expect(response).to have_http_status(:ok)
            #       expect(request_response.count).to eq(1)
            #       expect(request_response["tags"].count).to eq(10)
            #       expect(request_response["tags"]).to eq(tags)
            #     end
            #   end
            # end
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

  describe "GET /expenses/:id" do
    let!(:expense) { create(:expense, :pending, user: employees[0]) }
    let(:testing_expenses) { expense }
    let(:testing_employees) { employees[0] }

    context "when the user is logged in" do
      context 'when the tag exists' do
        let(:user_token) { authenticate_user(manager) }
        let(:headers) { authenticated_user_headers(user_token) }
        it 'returns an expense' do
          get "/expenses/#{expense.id}", headers: headers

          request_response = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          match_expense_fields_show(request_response, testing_expenses, manager, testing_employees)
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
      let!(:valid_params) { attributes_for(:expense, :pending).merge(user_id: employees[0]["id"]).to_json }
      let(:testing_expenses) { JSON.parse(valid_params) }
      let(:testing_employees) { employees[0] }

      it 'creates an expense' do
        post "/expenses", params: valid_params, headers: headers

        request_response = JSON.parse(response.body)["expense"]

        expect(response).to have_http_status(:created)
        match_expense_fields_create(request_response, testing_expenses, manager, testing_employees)
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
        let!(:expense) { create(:expense, :pending, user: employees[0]) }
        let(:valid_params) { { description: 'New Description' }.to_json }

        it 'updates an expense' do
          patch "/expenses/#{expense.id}", params: valid_params, headers: headers

          request_response = JSON.parse(response.body)["expense"]

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
        let!(:expense) { create(:expense, :pending, user: employees[0]) }

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

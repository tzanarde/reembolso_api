# frozen_string_literal: true

module MatchHelpers
  extend RSpec::SharedContext

  def match_expense_fields_index(request_response, expenses, manager, employees)
    expect(request_response.first)
      .to include("description", "date", "amount", "location", "status", "manager", "employee", "tags")

    request_response.each_with_index do |requested_expense, index|
      created_expense = expenses[index]

      expect(requested_expense).to include("description" => created_expense["description"],
                                           "date" => created_expense["date"].to_s,
                                           "amount" => created_expense["amount"].to_s,
                                           "location" => created_expense["location"],
                                           "status" => created_expense["status"])

      expect(requested_expense["manager"]).to include("id" => manager["id"],
                                                      "name" => manager["name"])

      assigned_employee = index < (expenses.count / 2).floor ? employees[0] : employees[1]
      expect(requested_expense["employee"]).to include("id" => assigned_employee["id"],
                                                       "name" => assigned_employee["name"])

      unless created_expense.tags.nil?
        expect(requested_expense["tags"].count).to eq(created_expense.tags.count)
        created_expense.tags.each do |tag|
          expect(requested_expense["tags"]).to include(tag.description)
        end
      end
    end
  end

  def match_expense_fields_show(request_response, expense, manager, employee)
    expect(request_response["expense"])
      .to include("description", "date", "amount", "location", "status", "manager", "employee", "tags")

      created_expense = expense
      requested_expense = request_response["expense"]

      expect(requested_expense).to include("description" => created_expense["description"],
                                          "date" => created_expense["date"].to_s,
                                          "amount" => created_expense["amount"].to_s,
                                          "location" => created_expense["location"],
                                          "status" => created_expense["status"])

      expect(requested_expense["manager"]).to include("id" => manager["id"],
                                                     "name" => manager["name"])

      assigned_employee = employee
      expect(requested_expense["employee"]).to include("id" => assigned_employee["id"],
                                                      "name" => assigned_employee["name"])
  end

  def match_expense_fields_create(request_response, expense, manager, employee)
    expect(request_response)
      .to include("description", "date", "amount", "location", "status", "manager", "employee", "tags")

      created_expense = expense
      requested_expense = request_response

      expect(requested_expense).to include("description" => created_expense["description"],
                                          "date" => created_expense["date"].to_s,
                                          "amount" => created_expense["amount"].to_s,
                                          "location" => created_expense["location"],
                                          "status" => created_expense["status"])

      expect(requested_expense["manager"]).to include("id" => manager["id"],
                                                     "name" => manager["name"])

      assigned_employee = employee
      expect(requested_expense["employee"]).to include("id" => assigned_employee["id"],
                                                      "name" => assigned_employee["name"])

      unless created_expense["tags"].nil?
        expect(requested_expense["tags"].count).to eq(created_expense["tags"].count)
        created_expense["tags"].each do |tag|
          expect(requested_expense["tags"]).to include(tag)
        end
      end
  end

  def match_expense_fields_update(request_response, expense, manager, employee, expense_updates)
    expect(request_response)
      .to include("description", "date", "amount", "location", "status", "manager", "employee", "tags")

      created_expense = expense
      requested_expense = request_response

      updated_expense = JSON.parse(created_expense.to_json).merge(expense_updates)

      expect(requested_expense).to include("description" => updated_expense["description"],
                                          "date" => updated_expense["date"].to_s,
                                          "amount" => updated_expense["amount"].to_s,
                                          "location" => updated_expense["location"],
                                          "status" => updated_expense["status"])

      expect(requested_expense["manager"]).to include("id" => manager["id"],
                                                     "name" => manager["name"])

      assigned_employee = employee
      expect(requested_expense["employee"]).to include("id" => assigned_employee["id"],
                                                      "name" => assigned_employee["name"])

      expect(requested_expense["tags"].count).to eq(updated_expense["tags"].count)
      unless updated_expense["tags"].nil?
        updated_expense["tags"].each do |tag|
          expect(requested_expense["tags"]).to include(tag)
        end
      end
  end
end

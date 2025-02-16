# frozen_string_literal: true

Rails.application.routes.draw do
  resources :tags
  devise_for :users, defaults: { format: :json },
                     controllers: { sessions: "users/sessions",
                                    registrations: "users/registrations" }

  get "up" => "rails/health#show", as: :rails_health_check
end

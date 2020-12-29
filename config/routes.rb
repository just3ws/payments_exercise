# frozen_string_literal: true

Rails.application.routes.draw do
  resources :loans, defaults: { format: :json }, as: 'loans' do
    resources :loan_payments, only: %i[create index show], path: 'payments', as: 'payments'
  end
end

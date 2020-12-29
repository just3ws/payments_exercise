# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoanPaymentsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/loans/22/payments')
        .to route_to(
          controller: 'loan_payments',
          action: 'index',
          loan_id: '22',
          format: :json
        )
    end

    it 'routes to #show' do
      expect(get: '/loans/22/payments/1')
        .to route_to(
          action: 'show',
          controller: 'loan_payments',
          format: :json,
          id: '1',
          loan_id: '22'
        )
    end

    it 'routes to #create' do
      expect(post: '/loans/22/payments')
        .to route_to(
          action: 'create',
          controller: 'loan_payments',
          format: :json,
          loan_id: '22'
        )
    end
  end
end

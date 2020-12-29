# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/loans/:loan_id/payments', type: :request do
  let(:loan) { Loan.create!(funded_amount: 87.36) }
  let(:payment) { loan.payments.create!(amount: 25.12) }

  describe 'GET /index' do
    context 'with valid loan_id' do
      before do
        loan.payments.create!(amount: 9.65)

        get(loan_payments_path(loan_id: loan.id))
      end

      it 'constructs the list of loan payments document' do
        actual = JSON.parse(response.body)
        expected = JSON.parse({
          loan_id: loan.id,
          payments: loan.payments.map { |payment| payment.as_json.except('loan_id', 'updated_at') }
        }.to_json)

        expect(actual).to eq(expected)
      end

      it { expect(response).to be_successful }
    end
  end

  describe 'show one payment' do
    before { get(loan_payment_url(loan_id: loan.id, id: payment.id)) }

    it 'renders the json response' do
      actual = JSON.parse(response.body)
      expected = JSON.parse({
        loan_id: loan.id,
        payment: loan.payments.find(payment.id).as_json.except('loan_id', 'updated_at')
      }.to_json)

      expect(actual).to eq(expected)
    end

    it { expect(response).to be_successful }

    context 'with invalid loan' do
      before { get(loan_payment_url(loan_id: 777, id: payment.id)) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.content_type).to eq('application/json') }
    end

    context 'with invalid payment' do
      before { get(loan_payment_url(loan_id: loan.id, id: 888)) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.content_type).to eq('application/json') }
    end
  end

  describe 'create new payment record' do
    context 'with valid parameters' do
      it 'creates a new LoanPayment' do
        expect do
          post(loan_payments_url(loan_id: loan.id), params: { payment: { amount: 12.3 } })
        end.to change(LoanPayment, :count).by(1)
      end

      it 'renders a JSON response with the new payment' do
        post(loan_payments_url(loan_id: loan.id), params: { payment: { amount: 11.04 } })

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with payment exceeding outstanding balance' do
      before { post(loan_payments_url(loan_id: loan.id), params: { payment: { amount: 11_111.22 } }) }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response.content_type).to eq('application/json') }
    end

    context 'with invalid parameters' do
      it 'does not create a new LoanPayment' do
        expect { post(loan_payments_url(loan_id: loan.id), params: { payment: {} }) }
          .to change(LoanPayment, :count).by(0)
      end
    end

    context 'with invalid loan' do
      before { post(loan_payments_url(loan_id: 999), params: { payment: { amount: 12.21 } }) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.content_type).to eq('application/json') }
    end

    context 'with missing parameters' do
      before { post(loan_payments_url(loan_id: loan.id), params: { payment: {} }) }

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(response.content_type).to eq('application/json') }
    end
  end
end

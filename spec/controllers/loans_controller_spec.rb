# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoansController, type: :controller do
  describe '#index' do
    let(:loan) { Loan.create!(funded_amount: 22.2) }

    before do
      loan
      get :index
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(JSON.parse(response.body).map { |l| l['balance'] }).to contain_exactly('22.2') }
    it { expect(response.content_type).to eq('application/json') }

    it 'renders the loans with their outstanding balances' do
      actual = JSON.parse(response.body)
      expected = JSON.parse([loan.as_json(methods: :balance)].to_json)

      expect(actual).to eq(expected)
    end
  end

  describe '#show' do
    let(:loan) { Loan.create!(funded_amount: 45.2) }

    before do
      loan
      get :show, params: { id: loan.id }
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(JSON.parse(response.body)['balance']).to eq('45.2') }
    it { expect(response.content_type).to eq('application/json') }

    it 'renders the loan with the outstanding balance' do
      actual = JSON.parse(response.body)
      expected = JSON.parse(loan.as_json(methods: :balance).to_json)

      expect(actual).to eq(expected)
    end

    context 'with invalid loan_id' do
      before { get :show, params: { id: 10_000 } }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response.content_type).to eq('application/json') }
    end
  end
end

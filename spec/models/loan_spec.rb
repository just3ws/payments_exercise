# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Loan, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:payments).inverse_of(:loan) }
    it { is_expected.to have_many(:payments).dependent(:destroy) }
    it { is_expected.to have_many(:payments).class_name('LoanPayment') }
  end

  describe '#balance' do
    subject(:loan) { described_class.create!(funded_amount: funded_amount) }

    context 'with positive funded_amount and no payments' do
      let(:funded_amount) { 100.0 }

      it { expect(loan.balance).to eq(funded_amount) }
    end

    context 'with empty funded_amount and no payments' do
      let(:funded_amount) { nil }

      it { expect(loan.balance).to be_zero }
    end

    context 'with negative funded_amount and no payments' do
      let(:funded_amount) { -1.to_d }

      it { expect(loan.balance).to be_negative }
      it { expect(loan.balance).to eq(funded_amount) }
    end

    context 'with positive funded_amount and an installment payment' do
      let(:funded_amount) { 100.to_d }
      let(:amount) { 10.to_d }

      before { loan.payments.create!(amount: amount) }

      it { expect(loan.balance).to eq(90.to_d) }
    end

    context 'with positive funded_amount and some installment payments' do
      let(:funded_amount) { 100.to_d }
      let(:payment_amounts) { [7.32, 9.78].map(&:to_d) }
      let(:total_payments) { payment_amounts.sum.to_d }
      let(:balance) { funded_amount - total_payments }

      before do
        payment_amounts.each do |payment_amount|
          loan.payments.create!(amount: payment_amount)
        end
      end

      it { expect(loan.balance).to eq(balance) }
    end
  end
end

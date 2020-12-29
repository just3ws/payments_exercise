# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoanPayment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:loan).inverse_of(:payments) }
    it { is_expected.to belong_to(:loan).touch(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:loan) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).on(:create) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }

    context 'with balance contingent amount validation' do
      # shoulda-matcher library validation of numericality with decimal values is broken

      let(:loan) { Loan.create!(funded_amount: 100.01) }
      let(:over_payment) { loan.payments.create(amount: 90.99) }

      before do
        loan
        loan.payments.create!(amount: 11.99)

        over_payment
      end

      it { expect(loan).not_to be_valid }
      it { expect(over_payment).not_to be_valid }
      it { expect(loan.balance.to_digits).to eq('88.02') }
      it {
        expect(over_payment.errors.full_messages).to contain_exactly("Amount must be less than or equal to #{loan.balance.to_digits}")
      }
    end
  end

  describe 'attributes' do
    it { is_expected.to have_readonly_attribute(:amount) }
  end
end

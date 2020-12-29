# frozen_string_literal: true

class Loan < ApplicationRecord
  has_many :payments,
           inverse_of: :loan,
           dependent: :destroy,
           class_name: 'LoanPayment'

  def balance
    return 0.0 if funded_amount.blank?

    funded_amount - payments.select(&:persisted?).sum(&:amount)
  end
end

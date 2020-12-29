# frozen_string_literal: true

class LoanPayment < ApplicationRecord
  belongs_to :loan, inverse_of: :payments, touch: true

  validates(:loan, presence: true, allow_blank: false)
  validates(:amount, presence: true)
  validates(:amount, numericality: { greater_than: 0 }, on: :create)
  validates(:amount, numericality: { less_than_or_equal_to: lambda { |loan_payment|
                                                              (loan_payment&.loan&.balance || 0).to_d
                                                            } }, on: :create)

  attr_readonly :amount
end

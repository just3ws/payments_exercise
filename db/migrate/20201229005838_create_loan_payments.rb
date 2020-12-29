# frozen_string_literal: true

class CreateLoanPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :loan_payments do |t|
      t.references :loan, foreign_key: true

      t.decimal :amount, precision: 8, scale: 2

      t.timestamps
    end
  end
end

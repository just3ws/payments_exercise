# frozen_string_literal: true

class LoanPaymentsController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |_e|
    render json: 'not_found', status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |e|
    render status: :bad_request, json: { error: e.message }
  end

  before_action :loan, only: %i[index show create]
  before_action :payment, only: [:show]

  def index
    render json: {
      loan_id: loan.id,
      payments: loan.payments.as_json.map { |payment| payment.except('loan_id', 'updated_at') }
    }
  end

  def show
    render json: {
      loan_id: loan.id,
      payment: payment.as_json.except('loan_id', 'updated_at')
    }
  end

  def create
    @payment = loan.payments.new(create_payment_params)

    if payment.save
      render json: { location: loan_payment_url(loan_id: loan.id, id: payment.id) },
             status: :created

      return
    end

    render json: payment.errors,
           status: :unprocessable_entity
  end

  private

  def loan
    @loan ||= Loan.find(params[:loan_id])
  end

  def payment
    @payment ||= loan.payments.find(params[:id])
  end

  def create_payment_params
    params.require(:payment).permit(:amount)
  end
end

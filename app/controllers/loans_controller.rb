# frozen_string_literal: true

class LoansController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render json: 'not_found',
           status: :not_found
  end

  def index
    render json: Loan.all,
           methods: :balance
  end

  def show
    render json: Loan.find(params[:id]),
           methods: :balance
  end
end

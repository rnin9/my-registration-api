class PaymentsController < ApplicationController
  include Authenticable

  before_action :set_payment, only: [ :show, :update, :destroy, :cancel, :complete ]

  # GET /payments
  def index
    query_opts = {
      status: params[:status],
      date_from: params[:from],
      date_to: params[:to]
    }
    skip = params[:skip]&.to_i || 0
    limit = params[:limit]&.to_i || 100

    payments = PaymentService.find_payments(
      query_opts: query_opts,
      skip: skip,
      limit: limit
    )

    render json: payments.map { |p| PaymentSerializer.new(p).as_json }
  end

  # GET /payments/my
  def my_payments
    query_opts = {
      status: params[:status],
      date_from: params[:from],
      date_to: params[:to]
    }
    skip = params[:skip]&.to_i || 0
    limit = params[:limit]&.to_i || 100

    payments = PaymentService.find_by_user(
      user_id: current_user.id,
      query_opts: query_opts,
      skip: skip,
      limit: limit
    )

    render json: payments.map { |p| PaymentSerializer.new(p).as_json }
  end

  # GET /payments/:id
  def show
    render json: PaymentSerializer.new(@payment).as_json
  end

  # POST /payments
  def create
    result = PaymentService.create(payment_params: payment_params)

    if result[:success]
      render json: PaymentSerializer.new(result[:payment]).as_json, status: :created
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # PATCH /payments/:id
  def update
    result = PaymentService.update(
      payment_id: @payment.id,
      payment_update: payment_update_params,
      user_id: current_user.id
    )

    if result[:success]
      render json: PaymentSerializer.new(result[:payment]).as_json
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # DELETE /payments/:id
  def destroy
    result = PaymentService.destroy(@payment.id, current_user.id)

    if result[:success]
      head :no_content
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # POST /payments/:id/restore
  def restore
    result = PaymentService.restore(params[:id], current_user.id)

    if result[:success]
      render json: PaymentSerializer.new(result[:payment]).as_json
    else
      status_code = result[:status] || :not_found
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # POST /tests/:id/apply
  # POST /courses/:id/apply
  def apply
    # polymorphic: test_id 또는 course_id
    target_type = controller_name.singularize
    target_id = params[:id]

    result = PaymentService.apply(
      target_type: target_type,
      target_id: target_id,
      payment_params: apply_params,
      user_id: current_user.id
    )

    if result[:success]
      render json: PaymentSerializer.new(result[:payment]).as_json, status: :created
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # POST /payments/:id/cancel
  def cancel
    result = PaymentService.cancel(params[:id], current_user.id)

    if result[:success]
      render json: PaymentSerializer.new(result[:payment]).as_json
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # POST /payments/:id/complete
  def complete
    result = PaymentService.complete(params[:id], current_user.id)

    if result[:success]
      render json: PaymentSerializer.new(result[:payment]).as_json
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  private

  def set_payment
    @payment = Payment.active.find_by(id: params[:id])

    unless @payment
      render json: { error: 'Payment not found' }, status: :not_found
    end
  end

  def payment_params
    params.require(:payment).permit(
      :actant_id,
      :amount,
      :method,
      :status,
      :target_type,
      :target_id,
      :title,
      :paid_at,
      :valid_from,
      :valid_to
    )
  end

  def payment_update_params
    params.require(:payment).permit(
      :amount,
      :method,
      :status,
      :target_type,
      :target_id,
      :title,
      :paid_at,
      :cancelled_at,
      :valid_from,
      :valid_to,
      :is_destroyed
    )
  end

  def apply_params
    params.permit(:amount, :method)
  end
end
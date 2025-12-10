module Payable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :apply ]
  end

  # POST /tests/:id/apply
  # POST /courses/:id/apply
  def apply
    target_type = controller_name.singularize # 'tests' → 'test', 'courses' → 'course'

    result = PaymentService.apply(
      target_type: target_type,
      target_id: params[:id],
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

  private

  def apply_params
    params.permit(:amount, :method)
  end
end
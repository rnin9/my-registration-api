module Payable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :apply ]
  end

  # POST /tests/:id/apply
  # POST /courses/:id/apply
  def apply
    target = controller_name.classify.constantize.active.find(params[:id])

    result = PaymentService.apply(
      target: target,
      payment_params: apply_params,
      user_id: current_user.id
    )

    if result[:success]
      render json: PaymentSerializer.new(result[:payment]).as_json, status: :created
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [ "Not found" ] }, status: :not_found
  end
end

private

def apply_params
  params.slice(:amount, :method).permit!
end

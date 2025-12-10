class PaymentSerializer
  def initialize(payment)
    @payment = payment
  end

  def as_json(*)
    {
      id: @payment.id,
      actant_id: @payment.actant_id,
      amount: @payment.amount,
      method: @payment.method,
      status: @payment.status,
      target_type: @payment.target_type,
      target_id: @payment.target_id,
      title: @payment.title,
      paid_at: @payment.paid_at,
      cancelled_at: @payment.cancelled_at,
      valid_from: @payment.valid_from,
      valid_to: @payment.valid_to,
      is_destroyed: @payment.is_destroyed,
      created_at: @payment.created_at,
      updated_at: @payment.updated_at
    }
  end
end
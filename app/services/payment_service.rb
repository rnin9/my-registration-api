class PaymentService
  # GET /payments
  def self.find_payments(query_opts:, skip:, limit:)
    payments = Payment.active
    payments = payments.by_status(query_opts[:status])
    payments = payments.date_range(query_opts[:date_from], query_opts[:date_to])
    payments = payments.by_created
    payments.paginate(skip: skip, limit: limit)
  end

  # GET /payments (사용자별)
  def self.find_by_user(user_id:, query_opts:, skip:, limit:)
    payments = Payment.active.by_user(user_id)
    payments = payments.by_status(query_opts[:status])
    payments = payments.date_range(query_opts[:date_from], query_opts[:date_to])
    payments = payments.by_created
    payments.paginate(skip: skip, limit: limit)
  end

  # POST /payments
  def self.create(payment_params:)
    payment = Payment.new(
      actant_id: payment_params[:user_id],
      amount: payment_params[:amount],
      method: payment_params[:method],
      status: payment_params[:status],
      target_type: payment_params[:target_type],
      target_id: payment_params[:target_id],
      title: payment_params[:title],
      paid_at: payment_params[:paid_at],
      valid_from: payment_params[:valid_from],
      valid_to: payment_params[:valid_to]
    )

    if payment.save
      { success: true, payment: payment }
    else
      { success: false, errors: payment.errors.full_messages, status: 422 }
    end
  end

  # PATCH /payments/:id
  def self.update(payment_id:, payment_update:, user_id:)
    payment = Payment.active.find_by(id: payment_id)

    unless payment
      return {
        success: false,
        errors: [ 'Payment not found' ],
        status: 404
      }
    end

    # 본인 결제만 수정 가능
    unless payment.actant_id == user_id
      return {
        success: false,
        errors: [ 'Not authorized' ],
        status: 403
      }
    end

    update_data = payment_update.compact

    if payment.update(update_data)
      payment.touch
      { success: true, payment: payment }
    else
      { success: false, errors: payment.errors.full_messages, status: 422 }
    end
  end

  # DELETE /payments/:id
  def self.destroy(payment_id, user_id)
    payment = Payment.active.find_by(id: payment_id)

    unless payment
      return {
        success: false,
        errors: [ 'Payment not found' ],
        status: 404
      }
    end

    unless payment.actant_id == user_id
      return {
        success: false,
        errors: [ 'Not authorized' ],
        status: 403
      }
    end

    if payment.soft_delete
      { success: true }
    else
      { success: false, errors: payment.errors.full_messages, status: 422 }
    end
  end

  # POST /payments/:id/restore
  def self.restore(payment_id, user_id)
    payment = Payment.destroyed.find_by(id: payment_id)

    unless payment
      return {
        success: false,
        errors: [ 'Payment not found' ],
        status: 404
      }
    end

    unless payment.actant_id == user_id
      return {
        success: false,
        errors: [ 'Not authorized' ],
        status: 403
      }
    end

    if payment.restore
      { success: true, payment: payment }
    else
      { success: false, errors: payment.errors.full_messages, status: 422 }
    end
  end

  def self.apply(target_type:, target_id:, payment_params:, user_id:)
    # Target 조회 (Test 또는 Course)
    target = find_target(target_type, target_id)

    unless target
      return {
        success: false,
        errors: [ "#{target_type.capitalize} not found" ],
        status: 404
      }
    end
    
    payment = Payment.new(
      actant_id: user_id,
      amount: payment_params[:amount],
      method: payment_params[:method],
      status: :pending,
      target_type: target_type.upcase,
      target_id: target_id,
      title: "#{target_type.capitalize}: #{target.title}",
      valid_from: target.start_at.to_date,
      valid_to: target.end_at.to_date
    )

    if payment.save
      { success: true, payment: payment }
    else
      { success: false, errors: payment.errors.full_messages, status: 422 }
    end
  end

  private

  def self.find_target(target_type, target_id)
    case target_type.downcase
    when 'test'
      Test.active.find_by(id: target_id)
    when 'course'
      Course.active.find_by(id: target_id)
    else
      nil
    end
  end
end

# POST /payments/:id/cancel
def self.cancel(payment_id, user_id)
  payment = Payment.active.find_by(id: payment_id)

  unless payment
    return { success: false, errors: [ 'Payment not found' ], status: 404 }
  end

  unless payment.actant_id == user_id
    return { success: false, errors: [ 'Not authorized' ], status: 403 }
  end

  if payment.cancel!
    { success: true, payment: payment }
  else
    { success: false, errors: payment.errors.full_messages, status: 422 }
  end
end

# POST /payments/:id/complete
def self.complete(payment_id, user_id)
  payment = Payment.active.find_by(id: payment_id)

  unless payment
    return { success: false, errors: [ 'Payment not found' ], status: 404 }
  end

  unless payment.actant_id == user_id
    return { success: false, errors: [ 'Not authorized' ], status: 403 }
  end

  if payment.complete!
    { success: true, payment: payment }
  else
    { success: false, errors: payment.errors.full_messages, status: 422 }
  end
end
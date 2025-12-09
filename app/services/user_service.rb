class UserService
  # GET /users
  def self.all
    User.active.order(created_at: :desc)
  end

  # POST /users
  def self.create(user_params)
    user = User.new(
      email: user_params[:email],
      name: user_params[:name],
      password: user_params[:password],
      password_confirmation: user_params[:password_confirmation]
    )

    if user.save
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages, status: 422 }
    end
  end

  # PATCH /users/:id
  def self.update(user_id:, user_update:, actant_id:)
    user = User.active.find_by(id: user_id)

    unless user
      return {
        success: false,
        errors: [ 'User not found' ],
        status: 404
      }
    end

    # 본인만 수정 가능
    unless user.id == actant_id
      return {
        success: false,
        errors: [ 'Not authorized' ],
        status: 403
      }
    end

    update_data = user_update.compact

    if user.update(update_data)
      user.touch
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages, status: 422 }
    end
  end

  # DELETE /users/:id
  def self.destroy(user_id, actant_id)
    user = User.active.find_by(id: user_id)

    unless user
      return {
        success: false,
        errors: [ 'User not found' ],
        status: 404
      }
    end

    unless user.id == actant_id
      return {
        success: false,
        errors: [ 'Not authorized' ],
        status: 403
      }
    end

    if user.soft_delete
      { success: true }
    else
      { success: false, errors: user.errors.full_messages, status: 422 }
    end
  end

  # POST /users/:id/restore
  def self.restore(user_id, actant_id)
    user = User.destroyed.find_by(id: user_id)

    unless user
      return {
        success: false,
        errors: [ 'User not found or not authorized' ],
        status: 404
      }
    end

    unless user.id == actant_id
      return {
        success: false,
        errors: [ 'Not authorized' ],
        status: 403
      }
    end

    if user.restore
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages, status: 422 }
    end
  end
end
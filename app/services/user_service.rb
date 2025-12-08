class UserService
  def self.all
    User.active
  end

  def self.find(id)
    User.active.find(id)
  end

  def self.create(params)
    user = User.new(params)

    if user.save
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages }
    end
  end

  def self.update(user, params)
    if user.update(params)
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages }
    end
  end

  def self.destroy(user)
    if user.soft_delete
      { success: true }
    else
      { success: false, errors: user.errors.full_messages }
    end
  end

  def self.restore(id)
    user = User.destroyed.find(id)
    if user.restore
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages }
    end
  end
end

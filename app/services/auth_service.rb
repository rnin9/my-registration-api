class AuthService
  def self.sign_in(email, password)
    user = User.active.find_by(email: email)

    if user&.authenticate(password)
      token = JsonWebToken.encode(user_id: user.id)

      {
        success: true,
        token: token,
        user: user,
        message: 'Signed in successfully'
      }
    else
      {
        success: false,
        error: 'Invalid email or password'
      }
    end
  end

  def self.sign_out
    {
      success: true,
      message: 'Signed out successfully'
    }
  end

  def self.verify_token(token)
    decoded = JsonWebToken.decode(token)
    return nil unless decoded

    User.active.find_by(id: decoded[:user_id])
  end

  def self.current_user_from_token(token)
    verify_token(token)
  end
end
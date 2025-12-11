module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  # JWT 토큰으로 사용자 인증
  def authenticate_user!
    token = extract_token_from_header

    if token
      decoded = JsonWebToken.decode(token)

      if decoded
        @current_user = User.active.find_by(id: decoded[:user_id])
      end
    end

    render_unauthorized unless @current_user
  end

  # 현재 로그인한 사용자
  def current_user
    @current_user
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    return nil unless header

    # "Bearer <token>" 형식
    header.split(' ').last if header.start_with?('Bearer ')
  end

  def render_unauthorized
    render json: {
      error: 'Unauthorized',
      message: 'Please provide a valid authentication token'
    }, status: :unauthorized
  end
end
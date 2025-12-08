module Auth
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!, only: [ :sign_in ], if: :authenticate_user_defined?

    # POST /auth/sign-in
    def sign_in
      result = AuthService.sign_in(
        sign_in_params[:email],
        sign_in_params[:password]
      )

      if result[:success]
        render json: {
          message: result[:message],
          token: result[:token],
          user: UserSerializer.new(result[:user]).as_json
        }, status: :ok
      else
        render json: {
          error: result[:error]
        }, status: :unauthorized
      end
    end

    # DELETE /auth/sign-out
    def sign_out
      result = AuthService.sign_out

      render json: {
        message: result[:message]
      }, status: :ok
    end

    # GET /auth/me
    def me
      render json: {
        user: UserSerializer.new(current_user).as_json
      }, status: :ok
    end

    private

    def sign_in_params
      params.require(:auth).permit(:email, :password)
    end

    def authenticate_user_defined?
      respond_to?(:authenticate_user!)
    end
  end
end
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]

  # GET /users
  def index
    users = UserService.all
    render json: users.map { |u| UserSerializer.new(u).as_json }
  end

  # GET /users/:id
  def show
    render json: UserSerializer.new(@user).as_json
  end

  # POST /users
  def create
    result = UserService.create(user_params)

    if result[:success]
      render json: UserSerializer.new(result[:user]).as_json, status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /users/:id
  def update
    result = UserService.update(@user, user_update_params)

    if result[:success]
      render json: UserSerializer.new(result[:user]).as_json
    else
      render json: { errors: result[:errors] }, status: :unprocessable_content
    end
  end

  # DELETE /users/:id (Soft Delete)
  def destroy
    result = UserService.destroy(@user)

    if result[:success]
      head :no_content
    else
      render json: { errors: result[:errors] }, status: :unprocessable_content
    end
  end

  # POST /users/:id/restore
  def restore
    result = UserService.restore(params[:id])

    if result[:success]
      render json: UserSerializer.new(result[:user]).as_json
    else
      render json: { errors: result[:errors] }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  private

  def set_user
    @user = UserService.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end
end

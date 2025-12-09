class UsersController < ApplicationController
  include Authenticate

  skip_before_action :authenticate_user!, only: [ :index, :show, :create ]
  before_action :set_user, only: [ :show, :update, :destroy ]

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
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # PATCH /users/:id
  def update
    result = UserService.update(
      user_id: @user.id,
      user_update: user_update_params,
      actant_id: current_user.id
    )

    if result[:success]
      render json: UserSerializer.new(result[:user]).as_json
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # DELETE /users/:id
  def destroy
    result = UserService.destroy(@user.id, current_user.id)

    if result[:success]
      head :no_content
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # POST /users/:id/restore
  def restore
    result = UserService.restore(params[:id], current_user.id)

    if result[:success]
      render json: UserSerializer.new(result[:user]).as_json
    else
      status_code = result[:status] || :not_found
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  private

  def set_user
    @user = User.active.find_by(id: params[:id])

    unless @user
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def user_params
    params.require(:user).permit(
      :email,
      :name,
      :password,
      :password_confirmation
    )
  end

  def user_update_params
    params.require(:user).permit(
      :email,
      :name,
      :password,
      :password_confirmation
    )
  end
end
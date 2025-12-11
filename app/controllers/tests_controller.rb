class TestsController < ApplicationController
  include Authenticable
  include Payable
  # 인증 불필요한 액션
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_test, only: [ :show, :update, :destroy ]

  # GET /tests?status=AVAILABLE&sort=created&skip=0&limit=100
  def index
    query_opts = {
      status: params[:status] || 'AVAILABLE',
      sort: params[:sort] || 'created'
    }
    skip = params[:skip]&.to_i || 0
    limit = params[:limit]&.to_i || 100

    tests = TestService.find_tests(
      query_opts: query_opts,
      skip: skip,
      limit: limit
    )

    render json: tests.map { |t| TestSerializer.new(t).as_json }
  end

  # GET /tests/:id
  def show
    render json: TestSerializer.new(@test).as_json
  end

  # POST /tests
  def create
    result = TestService.create_test(
      test_create: test_params,
      actant_id: current_user.id
    )

    if result[:success]
      render json: TestSerializer.new(result[:test]).as_json, status: :created
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # PATCH /tests/:id
  def update
    result = TestService.update_test(
      test_id: @test.id,
      test_update: test_update_params,
      actant_id: current_user.id
    )

    if result[:success]
      render json: TestSerializer.new(result[:test]).as_json
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # DELETE /tests/:id
  def destroy
    result = TestService.destroy(@test, current_user.id)

    if result[:success]
      head :no_content
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # POST /tests/:id/restore
  def restore
    result = TestService.restore(params[:id], current_user.id)

    if result[:success]
      render json: TestSerializer.new(result[:test]).as_json
    else
      status_code = result[:status] || :not_found
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  private

  def set_test
    @test = Test.active.find_by(id: params[:id])

    unless @test
      render json: { error: 'Test not found' }, status: :not_found
    end
  end

  def test_params
    params.require(:test).permit(
      :title,
      :description,
      :start_at,
      :end_at,
      :status
    )
  end

  def test_update_params
    params.require(:test).permit(
      :title,
      :description,
      :examinee_count,
      :start_at,
      :end_at,
      :status,
      :is_destroyed
    )
  end
end
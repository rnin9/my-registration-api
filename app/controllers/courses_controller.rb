class CoursesController < ApplicationController
  include Authenticate
  include Payable
  
  # 인증 불필요한 액션
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_course, only: [ :show, :update, :destroy ]

  # GET /courses?status=AVAILABLE&sort=created&skip=0&limit=100
  def index
    query_opts = {
      status: params[:status] || 'AVAILABLE',
      sort: params[:sort] || 'created'
    }
    skip = params[:skip]&.to_i || 0
    limit = params[:limit]&.to_i || 100

    courses = CourseService.find_courses(
      query_opts: query_opts,
      skip: skip,
      limit: limit
    )

    render json: courses.map { |c| CourseSerializer.new(c).as_json }
  end

  # GET /courses/:id
  def show
    render json: CourseSerializer.new(@course).as_json
  end

  # POST /courses
  def create
    result = CourseService.create_course(
      course_create: course_params,
      actant_id: current_user.id
    )

    if result[:success]
      render json: CourseSerializer.new(result[:course]).as_json, status: :created
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # PATCH /courses/:id
  def update
    result = CourseService.update_course(
      course_id: @course.id,
      course_update: course_update_params,
      actant_id: current_user.id
    )

    if result[:success]
      render json: CourseSerializer.new(result[:course]).as_json
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # DELETE /courses/:id
  def destroy
    result = CourseService.destroy(@course, current_user.id)

    if result[:success]
      head :no_content
    else
      status_code = result[:status] || :unprocessable_entity
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  # POST /courses/:id/restore
  def restore
    result = CourseService.restore(params[:id], current_user.id)

    if result[:success]
      render json: CourseSerializer.new(result[:course]).as_json
    else
      status_code = result[:status] || :not_found
      render json: { errors: result[:errors] }, status: status_code
    end
  end

  private

  def set_course
    @course = Course.active.find_by(id: params[:id])

    unless @course
      render json: { error: 'Course not found' }, status: :not_found
    end
  end

  def course_params
    params.require(:course).permit(
      :title,
      :description,
      :start_at,
      :end_at,
      :status
    )
  end

  def course_update_params
    params.require(:course).permit(
      :title,
      :description,
      :student_count,
      :start_at,
      :end_at,
      :status,
      :is_destroyed
    )
  end
end
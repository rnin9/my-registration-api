class CourseService
  # GET /courses - 목록 조회
  def self.find_courses(query_opts:, skip:, limit:)
    courses = Course.active
    courses = courses.by_status(query_opts[:status])
    courses = apply_sort(courses, query_opts[:sort])
    courses.paginate(skip: skip, limit: limit)
  end

  # POST /courses - 생성
  def self.create_course(course_create:, actant_id:)
    course = Course.new(
      title: course_create[:title],
      description: course_create[:description],
      start_at: course_create[:start_at],
      end_at: course_create[:end_at],
      status: course_create[:status],
      actant_id: actant_id
    )

    if course.save
      { success: true, course: course }
    else
      { success: false, errors: course.errors.full_messages, status: 422 }
    end
  end

  def self.update_course(course_id:, course_update:, actant_id:)
    course = Course.active.find_by(id: course_id)
    return { success: false, errors: [ 'Course not found' ], status: 404 } unless course
    return { success: false, errors: [ 'Not authorized' ], status: 403 } unless course.actant_id == actant_id

    course.with_lock do
      if course.update(course_update.compact)
        course.touch
        { success: true, course: course }
      else
        { success: false, errors: course.errors.full_messages, status: 422 }
      end
    end
  end

  # DELETE /courses/:id - Soft Delete
  def self.destroy(course, actant_id)
    unless course.actant_id == actant_id
      return {
        success: false,
        errors: [ 'Not authorized to delete this course' ],
        status: 403
      }
    end

    if course.soft_delete
      { success: true }
    else
      { success: false, errors: course.errors.full_messages, status: 422 }
    end
  end

  # POST /courses/:id/restore - 복원
  def self.restore(course_id, actant_id)
    course = Course.destroyed.by_actant(actant_id).find_by(id: course_id)

    unless course
      return {
        success: false,
        errors: [ 'Course not found or not authorized' ],
        status: 404
      }
    end

    if course.restore
      { success: true, course: course }
    else
      { success: false, errors: course.errors.full_messages, status: 422 }
    end
  end

  def self.bulk_update(course_updates, actant_id)
    results = []
    errors = []

    ActiveRecord::Base.transaction do
      course_updates.each do |course_id, update_params|
        course = Course.active.find_by(id: course_id)

        unless course
          errors << "Course #{course_id} not found"
          next
        end

        result = update_course(
          course_id: course_id,
          course_update: update_params,
          actant_id: actant_id
        )

        if result[:success]
          results << result[:course]
        else
          errors << "Course #{course_id}: #{result[:errors].join(', ')}"
          raise ActiveRecord::Rollback
        end
      end

      raise ActiveRecord::Rollback if errors.any?
    end

    if errors.any?
      { success: false, errors: errors, status: 500 }
    else
      { success: true, courses: results }
    end
  end

  private

  # 정렬 적용 (Scope 활용)
  def self.apply_sort(courses, sort)
    case sort
    when 'popular'
      courses.by_popular
    when 'created'
      courses.by_created
    else
      courses.by_created
    end
  end

end
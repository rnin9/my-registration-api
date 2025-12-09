class CourseSerializer
  def initialize(course)
    @course = course
  end

  def as_json(*)
    {
      id: @course.id,
      title: @course.title,
      description: @course.description,
      start_at: @course.start_at,
      end_at: @course.end_at,
      status: @course.status,
      is_destroyed: @course.is_destroyed,
      student_count: @course.student_count,
      actant_id: @course.actant_id,
      created_at: @course.created_at,
      updated_at: @course.updated_at
    }
  end
end
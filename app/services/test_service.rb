# app/services/test_service.rb
class TestService
  # GET /tests - 목록 조회
  def self.find_tests(query_opts:, skip:, limit:)
    tests = Test.active
    tests = tests.by_status(query_opts[:status])
    tests = apply_sort(tests, query_opts[:sort])
    tests.paginate(skip: skip, limit: limit)
  end

  # POST /tests - 생성
  def self.create_test(test_create:, actant_id:)
    # 비즈니스 로직: Title 중복 체크
    if Test.active.exists?(title: test_create[:title])
      return {
        success: false,
        errors: [ 'Test already registered' ],
        status: 409
      }
    end

    # 비즈니스 로직: startAt >= endAt 체크
    if test_create[:start_at] >= test_create[:end_at]
      return {
        success: false,
        errors: [ 'Cannot create this test on startAt with endAt' ],
        status: 400
      }
    end

    # 생성
    test = Test.new(
      title: test_create[:title],
      description: test_create[:description],
      start_at: test_create[:start_at],
      end_at: test_create[:end_at],
      status: test_create[:status],
      actant_id: actant_id
    )

    if test.save
      { success: true, test: test }
    else
      { success: false, errors: test.errors.full_messages, status: 422 }
    end
  end

  # PATCH /tests/:id - 수정
  def self.update_test(test_id:, test_update:, actant_id:)
    # Scope로 조회
    test = Test.active.find_by(id: test_id)

    # 비즈니스 로직: 존재 여부
    unless test
      return {
        success: false,
        errors: [ 'Test not found' ],
        status: 404
      }
    end

    # 비즈니스 로직: 권한 체크
    unless test.actant_id == actant_id
      return {
        success: false,
        errors: [ 'Not authorized to update this test' ],
        status: 403
      }
    end

    # 비즈니스 로직: startAt >= endAt 체크
    if test_update[:start_at].present? && test_update[:end_at].present?
      if test_update[:start_at] >= test_update[:end_at]
        return {
          success: false,
          errors: [ 'Cannot update this test on startAt with endAt' ],
          status: 400
        }
      end
    end

    # Row-level lock + update
    test.with_lock do
      update_data = test_update.compact

      if test.update(update_data)
        test.touch
        { success: true, test: test }
      else
        { success: false, errors: test.errors.full_messages, status: 422 }
      end
    end
  end

  # DELETE /tests/:id - Soft Delete
  def self.destroy(test, actant_id)
    # 비즈니스 로직: 권한 체크
    unless test.actant_id == actant_id
      return {
        success: false,
        errors: [ 'Not authorized to delete this test' ],
        status: 403
      }
    end

    if test.soft_delete
      { success: true }
    else
      { success: false, errors: test.errors.full_messages, status: 422 }
    end
  end

  # POST /tests/:id/restore - 복원
  def self.restore(test_id, actant_id)
    # Scope로 조회
    test = Test.destroyed.by_actant(actant_id).find_by(id: test_id)

    unless test
      return {
        success: false,
        errors: [ 'Test not found or not authorized' ],
        status: 404
      }
    end

    if test.restore
      { success: true, test: test }
    else
      { success: false, errors: test.errors.full_messages, status: 422 }
    end
  end

  private

  # 정렬 적용 (Scope 활용)
  def self.apply_sort(tests, sort)
    case sort
    when 'popular'
      tests.by_popular
    when 'created'
      tests.by_created
    else
      tests.by_created # 기본값
    end
  end
end
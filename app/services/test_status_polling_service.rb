class TestStatusPollingService
  def self.update_test_statuses
    Rails.logger.info "[Test Status] Checking test status updates..."

    started_count = update_to_in_progress
    completed_count = update_to_completed

    total = started_count + completed_count

    Rails.logger.info "[Test Status] Summary: #{total} test(s) updated"
    Rails.logger.info "[Test Status]   Started: #{started_count}, Completed: #{completed_count}"

    { started: started_count, completed: completed_count, total: total }
  end

  private

  # AVAILABLE → IN_PROGRESS
  def self.update_to_in_progress
    now = Time.current

    tests_to_start = Test.active
                         .where(status: 'AVAILABLE')
                         .where('start_at <= ?', now)

    count = tests_to_start.count
    return 0 if count.zero?

    Rails.logger.info "[Test Status] Found #{count} test(s) to start"

    tests_to_start.find_each do |test|
      test.update(status: 'IN_PROGRESS')
      Rails.logger.info "[Test Status]   Test ##{test.id} '#{test.title}' AVAILABLE → IN_PROGRESS"
    end

    count
  end

  # IN_PROGRESS → COMPLETED
  def self.update_to_completed
    now = Time.current

    tests_to_complete = Test.active
                            .where(status: 'IN_PROGRESS')
                            .where('end_at <= ?', now)

    count = tests_to_complete.count
    return 0 if count.zero?

    Rails.logger.info "[Test Status] Found #{count} test(s) to complete"

    tests_to_complete.find_each do |test|
      test.update(status: 'COMPLETED')
      Rails.logger.info "[Test Status]   Test ##{test.id} '#{test.title}' IN_PROGRESS → COMPLETED"
    end

    count
  end
end
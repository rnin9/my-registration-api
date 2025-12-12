class PaymentReminderService
  DAYS_BEFORE = 5

  def self.check_and_send_reminders
    Rails.logger.info "=" * 80
    Rails.logger.info "[Reminder Service] Starting payment reminder check"
    Rails.logger.info "[Reminder Service] Current time: #{Time.current}"
    Rails.logger.info "[Reminder Service] Target date: #{DAYS_BEFORE.days.from_now.to_date}"

    # Test + Course 통합 처리
    test_count = process_targets(model: Test)
    course_count = process_targets(model: Course)

    total = test_count + course_count
    Rails.logger.info "[Reminder Service] SUMMARY: #{test_count} test reminders + #{course_count} course reminders = #{total} total"
    Rails.logger.info "=" * 80

    { tests: test_count, courses: course_count, total: total }
  end

  private

  # Target(Test/Course) 처리
  def self.process_targets(model:)
    target_name = model.name

    Rails.logger.info "\n" + "-" * 80
    Rails.logger.info "[Reminder] Checking #{target_name}s starting in #{DAYS_BEFORE} days"

    now = Time.current
    target_end_date = DAYS_BEFORE.days.from_now

    # 지금 ~ 5일 후까지 (5일 이하 전부)
    targets = model.active
                   .where(status: 'AVAILABLE')
                   .where('start_at > ?', now)
                   .where('start_at <= ?', target_end_date.end_of_day)

    Rails.logger.info "[Reminder] Found #{targets.count} #{target_name.downcase}(s)"

    return 0 if targets.empty?

    # 2. Target ID들 추출
    target_ids = targets.pluck(:id).map(&:to_s)
    Rails.logger.info "[Reminder] Target IDs: [#{target_ids.join(', ')}]"

    # 3. 한 번에 모든 Pending Payment 조회
    pending_payments = Payment.active
                              .where(status: 'PENDING')
                              .where(target_type: model.name)
                              .where(target_id: target_ids)
                              .includes(:actant, :target)

    Rails.logger.info "[Reminder] Found #{pending_payments.count} pending payment(s)"

    return 0 if pending_payments.empty?

    # 4. Target별 Payment 수 로그
    payments_by_target = pending_payments.group_by(&:target_id)

    targets.each do |target|
      target_payments = payments_by_target[target.id.to_s] || []
      if target_payments.any?
        Rails.logger.info "[Reminder]   #{target_name} ##{target.id} '#{target.title}' - #{target_payments.count} payment(s)"
      end
    end

    # 5. 메일 발송
    reminder_count = 0

    pending_payments.each do |payment|
      target = payment.target # Polymorphic으로 자동 조회!

      if send_reminder(payment: payment, target: target)
        reminder_count += 1
      end
    end

    Rails.logger.info "[Reminder] #{target_name} reminders sent: #{reminder_count}"
    Rails.logger.info "-" * 80 + "\n"

    reminder_count
  end

  # 메일 발송
  def self.send_reminder(payment:, target:)
    user = payment.actant
    target_name = target.class.name # 'Test' 또는 'Course'

    Rails.logger.info "[Reminder] Sending reminder to #{user.email} (User ##{user.id})"
    Rails.logger.info "[Reminder] Payment: ##{payment.id} | Amount: #{number_with_delimiter(payment.amount)}원"
    Rails.logger.info "[Reminder] #{target_name}: '#{target.title}'"

    # 메일 발송
    PaymentReminderMailer.pending_payment_reminder(
      user: user,
      payment: payment,
      target: target
    ).deliver_later

    Rails.logger.info "[Reminder] Status: Email queued successfully"
    true
  rescue => e
    Rails.logger.error "[Reminder] ERROR: Failed to send reminder"
    Rails.logger.error "[Reminder] #{e.class}: #{e.message}"
    Rails.logger.error "[Reminder] Backtrace: #{e.backtrace.first(3).join(' | ')}"
    false
  end

  # Helper method
  def self.number_with_delimiter(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
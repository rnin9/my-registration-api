# config/initializers/scheduler.rb
require 'rufus-scheduler'

# Rails 서버가 시작될 때만 실행
return unless defined?(Rails::Server)

scheduler = Rufus::Scheduler.new

# 기본: 한국 시간 오전 9시
scheduler.cron '0 9 * * * Asia/Seoul' do
  Rails.logger.info "[Scheduler] Running daily payment reminder check (KST 09:00)"
  PaymentReminderService.check_and_send_reminders
end

# 개발 환경: 2분마다
if Rails.env.development?
  scheduler.every '2m' do
    Rails.logger.info "[Dev Scheduler] Running payment reminder check"
    PaymentReminderService.check_and_send_reminders
  end
end

# Polling Jobs (상태 감시)

# 1분마다: Test 상태 자동 변경
scheduler.every '1m' do
  Rails.logger.info "[Polling] Checking test statuses (every 1 minute)"
  TestStatusPollingService.update_test_statuses
end

Rails.logger.info "[Scheduler] Rufus-Scheduler started successfully"
Rails.logger.info "[Scheduler] Daily reminder: 09:00 KST (Asia/Seoul)"

Rails.logger.info "[Scheduler] Rufus-Scheduler started successfully"
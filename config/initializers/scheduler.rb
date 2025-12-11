# config/initializers/scheduler.rb
require 'rufus-scheduler'

# Rails 서버가 시작될 때만 실행
return unless defined?(Rails::Server)

scheduler = Rufus::Scheduler.new

scheduler.cron '0 0 * * *' do
  Rails.logger.info "=" * 80
  Rails.logger.info "[Scheduler] Starting payment reminder check..."
  Rails.logger.info "[Scheduler] Current time: #{Time.current}"

  PaymentReminderService.check_and_send_reminders

  Rails.logger.info "[Scheduler] Payment reminder check completed"
  Rails.logger.info "=" * 80
end

# 개발/테스트용: 2분마다 실행 (프로덕션에서는 제거)
if Rails.env.development?
  scheduler.every '2m' do
    Rails.logger.info "[Dev Scheduler] Running payment reminder check..."
    PaymentReminderService.check_and_send_reminders
  end
end

Rails.logger.info "✅ [Scheduler] Rufus-Scheduler started successfully"
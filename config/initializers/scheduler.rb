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

Rails.logger.info "[Scheduler] Rufus-Scheduler started successfully"
Rails.logger.info "[Scheduler] Daily reminder: 09:00 KST (Asia/Seoul)"

Rails.logger.info "[Scheduler] Rufus-Scheduler started successfully"
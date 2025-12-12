class PaymentReminderMailer < ApplicationMailer
  default from: 'noreply@example.com'

  def pending_payment_reminder(user:, payment:, target:)
    @user = user
    @payment = payment
    @target = target
    @target_type = target.class.name
    @target_name_ko = target.is_a?(Test) ? '시험' : '강의'
    @days_until_start = ((target.start_at - Time.current) / 1.day).ceil

    mail(
      to: @user.email,
      subject: "[결제 확인] #{@target.title} #{@target_name_ko}이(가) #{@days_until_start}일 후 시작됩니다"
    )
  end
end

private

def calculate_days_until_start(target)
  ((target.start_at - Time.current) / 1.day).ceil
end

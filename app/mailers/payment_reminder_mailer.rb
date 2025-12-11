class PaymentReminderMailer < ApplicationMailer
  default from: 'noreply@example.com'

  def pending_payment_reminder(user:, payment:, target:, target_type:)
    @user = user
    @payment = payment
    @target = target
    @target_type = target_type
    @days_until_start = calculate_days_until_start(target)

    # target_type에 따른 한글 명칭
    @target_name_ko = target_type == 'test' ? '시험' : '강의'
    @target_action_ko = target_type == 'test' ? '응시' : '수강'

    mail(
      to: @user.email,
      subject: "[결제 확인 필요] #{@target.title} #{@target_name_ko}이(가) #{@days_until_start}일 후 시작됩니다"
    )
  end

  private

  def calculate_days_until_start(target)
    ((target.start_at - Time.current) / 1.day).ceil
  end
end
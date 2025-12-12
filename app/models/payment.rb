class Payment < ApplicationRecord
  include SoftDeletable

  # Associations
  belongs_to :actant, class_name: 'User', foreign_key: :actant_id
  belongs_to :target, polymorphic: true, foreign_key: :target_id

  # Enums
  enum method: {
    card: 'CARD',
    bank_transfer: 'BANK_TRANSFER',
    virtual_account: 'VIRTUAL_ACCOUNT',
    mobile: 'MOBILE',
    kakaopay: 'KAKAOPAY',
    naverpay: 'NAVERPAY'
  }, _prefix: true, _default: nil

  enum status: {
    pending: 'PENDING',
    completed: 'COMPLETED',
    cancelled: 'CANCELLED',
    failed: 'FAILED',
    refunded: 'REFUNDED'
  }, _prefix: true

  # Validations
  validates :actant_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :title, presence: true
  validates :valid_from, presence: true
  validates :valid_to, presence: true

  scope :by_user, ->(user_id) { where(actant_id: user_id) if actant_id.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_target_type, ->(target_type) { where(target_type: target_type) if target_type.present? }
  scope :by_target, ->(target_type, target_id) {
    where(target_type: target_type, target_id: target_id) if target_type.present? && target_id.present?
  }

  # Scopes - 날짜 필터링
  scope :date_from, ->(from_date) { where('valid_from >= ?', from_date) if from_date.present? }
  scope :date_to, ->(to_date) { where('valid_to <= ?', to_date) if to_date.present? }
  scope :date_range, ->(from_date, to_date) {
    scope = all
    scope = scope.date_from(from_date) if from_date.present?
    scope = scope.date_to(to_date) if to_date.present?
    scope
  }

  # Scopes - 정렬
  scope :by_created, -> { order(created_at: :desc) }
  scope :by_amount, -> { order(amount: :desc) }
  scope :by_paid_at, -> { order(paid_at: :desc) }
  scope :paginate, ->(skip:, limit:) { offset(skip).limit(limit) }

  # Instance Methods
  def cancel!
    update(status: :cancelled, cancelled_at: Time.current)
  end

  def complete!
    update(status: :completed, paid_at: Time.current)
  end

  def refund!
    update(status: :refunded)
  end
end
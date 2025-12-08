class Test < ApplicationRecord
  # Associations
  belongs_to :actant, class_name: 'User'

  # Enums
  enum status: {
    available: 'AVAILABLE',
    in_progress: 'IN_PROGRESS',
    completed: 'COMPLETED',
    cancelled: 'CANCELLED'
  }, _prefix: true

  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validate :end_at_after_start_at

  # Scopes
  scope :active, -> { where(is_destroyed: false) }
  scope :destroyed, -> { where(is_destroyed: true) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_created, -> { order(created_at: :desc) }
  scope :by_popular, -> { order(examinee_count: :desc) }

  # Soft Delete
  def soft_delete
    update(is_destroyed: true)
  end

  def restore
    update(is_destroyed: false)
  end

  private

  def end_at_after_start_at
    return if end_at.blank? || start_at.blank?

    if end_at < start_at
      errors.add(:end_at, "must be after start_at")
    end
  end
end

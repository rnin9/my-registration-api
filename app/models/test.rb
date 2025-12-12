class Test < ApplicationRecord
  include SoftDeletable

  belongs_to :actant, class_name: 'User'
  has_many :payments, as: :target

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

  # Scopes
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_actant, ->(actant_id) { where(actant_id: actant_id) if actant_id.present? }
  scope :by_created, -> { order(created_at: :asc) }
  scope :by_popular, -> { order(examinee_count: :desc) }
  scope :paginate, ->(skip:, limit:) { offset(skip).limit(limit) }

end
# app/models/course.rb
class Course < ApplicationRecord
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

  # Scopes
  scope :active, -> { where(is_destroyed: false) }
  scope :destroyed, -> { where(is_destroyed: true) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_actant, ->(actant_id) { where(actant_id: actant_id) if actant_id.present? }
  scope :by_created, -> { order(created_at: :asc) }
  scope :by_popular, -> { order(student_count: :desc) }
  scope :paginate, ->(skip:, limit:) { offset(skip).limit(limit) }

  # Instance Methods
  def soft_delete
    update(is_destroyed: true)
  end

  def restore
    update(is_destroyed: false)
  end
end
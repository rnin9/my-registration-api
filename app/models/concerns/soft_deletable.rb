module SoftDeletable
  extend ActiveSupport::Concern

  included do
    # 기본값 설정
    after_initialize :set_default_is_destroyed, if: :new_record?

    # Scopes
    scope :active, -> { where(is_destroyed: false) }
    scope :destroyed, -> { where(is_destroyed: true) }
  end

  # Instance Methods
  def soft_delete
    update(is_destroyed: true)
  end

  def restore
    update(is_destroyed: false)
  end

  private

  def set_default_is_destroyed
    self.is_destroyed ||= false
  end
end
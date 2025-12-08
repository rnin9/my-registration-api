class User < ApplicationRecord
  has_secure_password # bcrypt로 password 암호화

  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }

  # Soft Delete 스코프
  scope :active, -> { where(is_destroyed: false) }
  scope :destroyed, -> { where(is_destroyed: true) }

  # 소프트 삭제 메소드
  def soft_delete
    update(is_destroyed: true)
  end

  # 복원 메소드
  def restore
    update(is_destroyed: false)
  end

  # 삭제 여부 확인
  def destroyed?
    is_destroyed
  end
end
class User < ApplicationRecord
  include SoftDeletable

  has_secure_password # bcrypt로 password 암호화

  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }
  
  # 삭제 여부 확인
  def destroyed?
    is_destroyed
  end

  def set_default_is_destroyed
    self.is_destroyed ||= false
  end
end
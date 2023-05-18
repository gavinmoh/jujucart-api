class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable

  has_many :sessions, dependent: :destroy
  has_many :notifications, dependent: :destroy, foreign_key: :recipient_id
  has_many :notification_tokens, dependent: :destroy, foreign_key: :recipient_id

  def active_for_authentication?
    super && self.active?
  end

  def badge_count
    self.notifications.unread.count
  end
end

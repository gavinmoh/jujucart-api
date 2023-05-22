class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable

  has_one  :latest_session, -> { order(created_at: :desc) }, class_name: 'Session'
  has_many :sessions, dependent: :destroy
  has_many :notifications, dependent: :destroy, foreign_key: :recipient_id
  has_many :notification_tokens, dependent: :destroy, foreign_key: :recipient_id

  def last_sign_in_at
    self.latest_session&.created_at
  end

  def last_sign_in_ip
    self.latest_session&.remote_ip
  end

  def active_for_authentication?
    super && self.active?
  end

  def badge_count
    self.notifications.unread.count
  end
end

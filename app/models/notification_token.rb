class NotificationToken < ApplicationRecord
  belongs_to :recipient, class_name: 'Account', optional: true

  validates :token, presence: true, uniqueness: true
end

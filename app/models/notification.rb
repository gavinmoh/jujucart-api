class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'Account'
  belongs_to :record, polymorphic: true, optional: true

  scope :unread, -> { where(read_at: nil) }

  def mark_as_read!
    return if self.read_at.present?
    self.update!(read_at: Time.current)
  end
end

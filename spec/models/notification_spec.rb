require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { should belong_to(:recipient) }
    it { should belong_to(:record).optional }
  end

  describe 'methods' do
    context '#mark_as_read!' do
      it 'should mark notification as read' do
        notification = create(:notification)
        notification.mark_as_read!
        expect(notification.read_at).not_to be_nil
      end
    end
  end

  describe 'scopes' do
    context 'unread' do
      let!(:read_notification) { create(:notification, read_at: Time.current) }
      let!(:unread_notification) { create(:notification) }

      it 'should return unread notifications' do
        notifications = Notification.unread
        expect(notifications).to match_array([unread_notification])
        expect(notifications).not_to include(read_notification)
      end
    end
  end
end

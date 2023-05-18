class Session < ApplicationRecord
  belongs_to :account

  has_secure_token :token, length: 128

  def revoke!
    self.update(revoked_at: Time.now) if revoked_at.nil?
  end

  def revoked?
    self.revoked_at.present?
  end

  def expired?
    self.expired_at.present? && self.expired_at < Time.current.utc
  end
end

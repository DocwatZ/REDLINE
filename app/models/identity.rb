# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }

  # Encrypt OAuth tokens at rest
  encrypts :access_token
  encrypts :refresh_token

  def token_expired?
    expires_at.present? && expires_at < Time.current
  end
end

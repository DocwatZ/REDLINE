# frozen_string_literal: true

class AuditLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user) { where(user: user) }

  # Convenience method for logging
  def self.log(action:, user: nil, metadata: {}, ip_address: nil)
    create!(
      action: action,
      user: user,
      metadata: metadata,
      ip_address: ip_address
    )
  end
end

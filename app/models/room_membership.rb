# frozen_string_literal: true

class RoomMembership < ApplicationRecord
  belongs_to :room
  belongs_to :user

  ROLES = %w[member moderator admin].freeze

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :room_id }

  def admin?
    role == "admin"
  end

  def moderator?
    role == "moderator" || admin?
  end
end

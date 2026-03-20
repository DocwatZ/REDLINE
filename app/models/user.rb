# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :trackable

  has_many :room_memberships, dependent: :destroy
  has_many :rooms, through: :room_memberships
  has_many :owned_rooms, class_name: "Room", foreign_key: :owner_id, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :sent_direct_messages, class_name: "DirectMessage",
           foreign_key: :sender_id, dependent: :destroy
  has_many :received_direct_messages, class_name: "DirectMessage",
           foreign_key: :recipient_id, dependent: :destroy

  STATUSES = %w[online away busy offline].freeze
  AVATAR_COLORS = %w[#e53e3e #dd6b20 #d69e2e #38a169 #3182ce #805ad5 #d53f8c].freeze

  validates :display_name, presence: true, length: { minimum: 2, maximum: 32 }
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_defaults, on: :create

  def online?
    status == "online"
  end

  def initials
    display_name.split.map(&:first).first(2).join.upcase
  end

  def dm_partner?(user)
    DirectMessage.between(id, user.id).exists?
  end

  private

  def set_defaults
    self.display_name = email.split("@").first if display_name.blank?
    self.avatar_color = AVATAR_COLORS.sample if avatar_color.blank?
  end
end

# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :room_memberships, dependent: :destroy
  has_many :members, through: :room_memberships, source: :user
  has_many :messages, dependent: :destroy

  ROOM_TYPES = %w[text voice announcement].freeze

  validates :name, presence: true, length: { minimum: 2, maximum: 64 },
            format: { with: /\A[a-zA-Z0-9\-_\s]+\z/, message: "only letters, numbers, spaces, hyphens, underscores" }
  validates :room_type, inclusion: { in: ROOM_TYPES }
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create
  after_create :add_owner_as_admin

  scope :public_rooms, -> { where(private: false) }
  scope :by_name, -> { order(:name) }

  def text?
    room_type == "text"
  end

  def voice?
    room_type == "voice"
  end

  def announcement?
    room_type == "announcement"
  end

  def member?(user)
    members.include?(user)
  end

  def membership_for(user)
    room_memberships.find_by(user: user)
  end

  private

  def generate_slug
    self.slug ||= name.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/(^-|-$)/, "")
    self.slug = "#{slug}-#{SecureRandom.hex(4)}" if Room.exists?(slug: slug)
  end

  def add_owner_as_admin
    room_memberships.create!(user: owner, role: "admin")
  end
end
